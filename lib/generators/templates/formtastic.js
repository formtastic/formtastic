(function($) {
    $.formtastic = function(options) {
        this.settings = $.extend({}, $.formtastic.defaults, options);
    };

    $.extend($.formtastic, {
        defaults: {},

        prototype: {
            autofocusSupported: function() {
                var input = document.createElement("input");
                return "autofocus" in input;
            },

            autofocus: function() {
                if (this.autofocusSupported() == false) {
                    $(':input[autofocus]:not(:hidden)').last().focus();
                }
            }
        }
    });
})(jQuery);

var formtastic = new $.formtastic();

$(document).ready(function() {
    formtastic.autofocus();
});
