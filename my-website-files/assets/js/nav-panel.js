(function($) {

    $.fn.generateNavList = function() {
        const $nav = $(this);
        const $links = $nav.find('a');
        let listHtml = [];

        $links.each(function() {
            const $link = $(this);
            const indent = Math.max(0, $link.parents('li').length - 1);
            const href = $link.attr('href');
            const target = $link.attr('target');

            let linkTag =
                `<a class="link depth-${indent}"
                    ${(target ? `target="${target}"` : '')}
                    ${(href ? `href="${href}"` : '')}>
                    <span class="indent-${indent}"></span>
                    ${$link.text()}
                </a>`;

            listHtml.push(linkTag);
        });

        return listHtml.join('');
    };


    $.fn.initPanel = function(userConfig) {
        if (this.length === 0) return this;
        if (this.length > 1) {
            this.each(function() { $(this).initPanel(userConfig); });
            return this;
        }

        const $panel = $(this);
        const $body = $('body');
        const panelId = $panel.attr('id');

        const config = $.extend({
            delay: 500,
            hideOnClick: true,
            hideOnSwipe: true,
            resetScroll: true,
            resetForms: true,
            side: 'left',
            target: $body,
            visibleClass: 'navPanel-visible'
        }, userConfig);

        $panel._hide = function(event) {
            if (!config.target.hasClass(config.visibleClass)) return;
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            config.target.removeClass(config.visibleClass);

            window.setTimeout(() => {
                if (config.resetScroll) $panel.scrollTop(0);
                if (config.resetForms) $panel.find('form').each(function() { this.reset(); });
            }, config.delay);
        };

        let touchPosX = null;
        $panel.on('touchstart', function(event) {
            touchPosX = event.originalEvent.touches[0].pageX;
        });

        $panel.on('touchmove', function(event) {
            if (touchPosX === null) return;

            const diffX = touchPosX - event.originalEvent.touches[0].pageX;
            const boundary = 20;
            const delta = 50;
            let swiped = false;

            switch (config.side) {
                case 'left':
                    swiped = diffX > delta;
                    break;
                case 'right':
                    swiped = diffX < -delta;
                    break;
            }

            if (swiped && config.hideOnSwipe) {
                touchPosX = null;
                $panel._hide();
            }
        });

        $panel.on('click touchend touchstart touchmove', (event) => {
            event.stopPropagation();
        });

        $body.on('click touchend', (event) => {
            $panel._hide(event);
        });

        $body.on('click', `a[href="#${panelId}"]`, (event) => {
            event.preventDefault();
            event.stopPropagation();
            config.target.toggleClass(config.visibleClass);
        });

        return $panel;
    };

})(jQuery);