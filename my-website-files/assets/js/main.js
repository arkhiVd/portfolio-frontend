(function($) {
    const $window = $(window);
    const $body = $('body');

    $window.on('load', function() {
        window.setTimeout(function() {
            $body.removeClass('is-preload');
        }, 100);
    });

    const $titleBar = $(
        '<div id="titleBar">' +
            '<a href="#navPanel" class="toggle"></a>' +
        '</div>'
    ).appendTo($body);

    const $navPanel = $(
        '<div id="navPanel">' +
            '<nav>' +
                $('#nav').generateNavList() + 
            '</nav>' +
        '</div>'
    )
    .appendTo($body)
    .initPanel({ 
        delay: 500,
        hideOnClick: true,
        hideOnSwipe: true,
        resetScroll: true,
        resetForms: true,
        side: 'left',
        target: $body,
        visibleClass: 'navPanel-visible'
    });

})(jQuery);