$(document).ready(function() {
    Handlebars.registerHelper('join', function(arr) {
        return new Handlebars.SafeString(
            arr.join(", ")
        );
    });

    Handlebars.registerHelper("debug", function(optionalValue) {
        console.log("Current Context");
        console.log("====================");
        console.log(this);

        if (optionalValue) {
            console.log("Value");
            console.log("====================");
            console.log(optionalValue);
        }
    });

    $('#btnSearch').button();

    $("#btnSearch").click(function() {
        $(this).button('loading');
        var query = $("input.search-query").val();

        if (query == '') {
            alert('Your search was blank');
            $("input.search-query").focus();
            $(this).button('reset');
            return false;
        }

        $.getJSON('/search',
            { q: query },
            function(data) {
//                console.log(data.items);

                var template = Handlebars.compile($("#booklist-template").html());
                Handlebars.registerPartial("book", $("#book-partial").html());

                if ($("#searchResults"))
                    $("#searchResults").empty();
                $("#searchResults").append(template(data));

                $("#btnSearch").button('reset');
            }
        );
    });
});