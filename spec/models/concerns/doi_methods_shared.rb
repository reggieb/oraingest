require 'rails_helper'

shared_examples_for "doi_methods" do

  let(:model) { described_class.new }

  def publication_params
    {
        'publicationStatus' => '',
        'reviewStatus' => '',
        'publisher_attributes' => {
            '0' => {
                'agent_attributes' => {
                    '0' => {
                        'name' => '',
                        'website' => ''
                    }
                }
            }
        },
        'dateAccepted' => '2014-12-01',
        'datePublished' => '2015-02-23',
        'location' => '',
        'hasDocument_attributes' => {
            '0' => {
                'doi' => '10.5072/bodleian:nn999n999',
                'uri' => '',
                'identifier' => '',
                'series_attributes' => {
                    '0' => {
                        'title' => ''
                    }
                },
                'journal_attributes' => {
                    '0' => {
                        'title' => '',
                        'issn'=> '',
                        'eissn' => '',
                        'volume' => '',
                        'issue' => '',
                        'pages' => ''
                    }
                }
            }
        }
    }.with_indifferent_access
  end

  describe '#doi' do
    context ' when publication is present' do
      before do
        MetadataBuilder.new(model).buildPublicationActivity(publication_params)
      end

      it 'returns the doi' do
        if model.is_a?(Dataset)
          expect(model.doi).to eq('10.5072/bodleian:nn999n999')
        else
          expect(model.doi).to be_nil
        end
      end
    end

    context ' when publication is not present' do
      context 'when mint is true' do
        it 'returns the doi' do
          if model.is_a?(Dataset)
            expect(model.doi()).not_to be_nil
            expect(model.doi(true)).not_to be_nil
          else
            expect(model.doi).to be_nil
            expect(model.doi(true)).to be_nil
          end
        end
      end
      context 'when mint is false' do
        it 'returns nil' do
          expect(model.doi(false)).to be_nil
        end
      end
    end
  end

  describe '#doi_requested?' do
    # Need to use dummy objects so as to mock presence of workflows.
    let(:workflow) do
      Struct.new 'Workflow' do
        def involves
          [Sufia.config.doi_event]
        end
      end
    end
    
    let(:dummy_model) do
      Struct.new 'DummyModel' do
        include DoiMethods
        
        def workflows
          @workflows ||= []
        end
      end
    end
    let(:model) { dummy_model.new }
    
    context 'when workflows are present' do
      
      it 'returns true' do
        model.workflows << workflow.new
        expect(model.doi_requested?).to be true
      end
    end
    
    context 'when workflows are not present' do
      it 'returns false' do
        expect(model.doi_requested?).to be false
      end
    end

  end

  describe '#doi_data' do
    before do
      model.title = 'Some article'
      MetadataBuilder.new(model).buildPublicationActivity(publication_params)

      creation_params = {
              :creator_attributes => {
                  '0' => {
                      'name' => 'Joe Creator',
                      'email' => '',
                      'sameAs' => '',
                      'role' => [],
                      'affiliation' => {
                          'name' => 'An affiliation',
                          'sameAs' => ''
                      }
                  }
              }
          }.with_indifferent_access
      MetadataBuilder.new(model).buildCreationActivity(creation_params)

      subject_params = {
          '0' => {
              'subjectLabel' => 'Substance abuse',
              'subjectAuthority' => 'http://id.worldcat.org/fast/01136767',
              'subjectScheme' => 'FAST'
          },
          '1' => {
              'subjectLabel' => 'Alcoholism',
              'subjectAuthority' => 'http://id.worldcat.org/fast/00804461',
              'subjectScheme' => 'FAST'
          }
      }.with_indifferent_access
      MetadataBuilder.new(model).buildSubject(subject_params)
    end

    it 'returns the doi_data' do
      if model.is_a?(Dataset)
        data = model.doi_data
        expect(data).not_to be_nil
        expect(data[:resourceType]).to eq('Dataset')
        expect(data[:resourceTypeGeneral]).to eq('Dataset')
        expect(data[:title]).to eq('Some article')
        expect(data[:identifier]).to eq('10.5072/bodleian:nn999n999')
        expect(data[:publisher]).to eq('University of Oxford')
        expect(data[:creator]).to be_an(Array)
        expect(data[:contributor]).to be_an(Array)
        expect(data[:subject]).to be_an(Array)
        expect(data[:subject].size).to eq(2)
        expect(data[:rights]).to be_an(Array)
        expect(data[:description]).to be_an(Array)
      end
    end
  end

  describe '#normalize_doi' do
    it 'returns the normalized doi with prefix' do
      expect(model.normalize_doi(:foo)).to eq('doi:foo')
    end
    
    it 'returns value if with_prefix = false' do
      expect(model.normalize_doi(:foo, false)).to eq('foo')
    end
    
    it 'returns value without prefix if with_prefix = false' do
      expect(model.normalize_doi('doi:foo', false)).to eq('foo')
    end
    
    it 'returns value without url' do
      resolver_url = Sufia.config.doi_credentials[:resolver_url]
      expect(model.normalize_doi("#{resolver_url}foo")).to eq('doi:foo')
    end
  end

  describe '#remote_uri_for' do
    it 'returns the remote uri' do
      resolver_url = Sufia.config.doi_credentials[:resolver_url]
      expected = URI.parse File.join(resolver_url, 'identifier')
      expect(model.remote_uri_for('identifier')).to eq(expected)
    end
  end
end
