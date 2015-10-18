class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper
 
  test "should parse the simple query string into a Hash" do
  	qs = "status=Claimed,type=Published"
    hsh = query_string_to_hash(qs)
    assert_equal(2, hsh.size)
    assert_equal(:status, hsh.keys[0])
    assert_equal(:type, hsh.keys[1])
    assert_equal('Claimed', hsh[:status])
    assert_equal('Published', hsh[:type])
  end

  test "should parse the negating query string into a Hash" do
  	qs = "status=!Claimed,type=Published"
    hsh = query_string_to_hash(qs)
    assert_equal(2, hsh.size)
    assert_equal(:status, hsh.keys[0])
    assert_equal(:type, hsh.keys[1])
    assert_equal('!Claimed', hsh[:status])
    assert_equal('Published', hsh[:type])
    assert_nil(hsh[:status!])
  end

  test "should add facet value to query string" do
  	# TODO:
  end

  test "should remove facet value from query string" do
  	# TODO:
  end


end