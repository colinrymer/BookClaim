$(document).ready(function() {
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

        $.getJSON('/ajax_search',
            { q: query },
            function(data) {
                console.log(data);

                var template = Handlebars.compile($("#booklist-template").html());
                Handlebars.registerPartial("book", $("#book-partial").html());
                template(data);

                $("#btnSearch").button('reset');
            }
        );
    });

    // TODO: Maybe register this elsewhere
    Handlebars.registerHelper('join', function(arr) {
        return new Handlebars.SafeString(
            arr.join(", ")
        );
    });
});