
$(document).ready(function() {


    $('#thesis_degreeName').change(
        function() {
            var degree_type;

            switch (this.value) {
                case 'DPhil':
                case 'PhD':
                    degree_type = 'Doctoral'
                    break;
                case 'MSc':
                case 'MSc by Research':
                case 'MPhil':
                case 'M.St.':
                case 'MLitt':
                    degree_type = 'Masters'
                    break;
                case 'BLitt':
                case 'BPhil':
                case 'Bachelor of Divinity (B.D.)':
                    degree_type = "Bachelors";
                    break;
                default:
                    degree_type = "Unknown";
            }

            $('#thesis_degreeType').val(degree_type);
        });

    $('#thesis_hasThirdPartyCopyrightMaterial_yes').click(
        function() {
        	$('#has_copyright_material').removeClass( "hidden-form" );
        	$('#hasnt_copyright_material').addClass( "hidden-form" );
            // if (this.checked && this.value == 'Yes') {
            // note that, as per comments, the 'changed'
            // <input> will *always* be checked, as the change
            // event only fires on checking an <input>, not
            // on un-checking it.
            // append goes here
        }
    );
    $('#thesis_hasThirdPartyCopyrightMaterial_no').click(
        function() {
        	$('#hasnt_copyright_material').removeClass( "hidden-form" );
        	$('#has_copyright_material').addClass( "hidden-form" );
        }
    );

});