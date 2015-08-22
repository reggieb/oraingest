
$(document).ready(function() {
    // $("#thesis_degreeName").on('click', function(){
    // alert("thesis_degreeName clicked");
    // });

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

    $('#thesis_hasThirdPartyCopyrightMaterial_yes').change(
        function() {
            if (this.checked && this.value == 'Yes') {
                alert("test");
                // note that, as per comments, the 'changed'
                // <input> will *always* be checked, as the change
                // event only fires on checking an <input>, not
                // on un-checking it.
                // append goes here
            }
        });


});