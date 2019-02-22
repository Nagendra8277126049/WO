// **************************
// CustomFacetPopup component
// **************************
var CustomFacetPopup = (function (_super) {
        __extends(CustomFacetPopup, _super);
        function CustomFacetPopup(element, options, bindings, id) {
            var _this = this;
            if (id === void 0) { id = CustomFacetPopup.ID; }
            _super.call(this, element, id, bindings);
            this.element = element;
            this.options = options;
            this.bindings = bindings;
            this.id = id;
            this.isOpen = false;
            this.options = Coveo.ComponentOptions.initComponentOptions(element, CustomFacetPopup, options);
            this.popupWrapper = $('<div></div>')
                .addClass('coveo-box-popup-wrapper')
                .appendTo(this.element);
            $(this.element).children().appendTo(this.popupWrapper);
            this.buildToggleButton();
            this.close();
            if (this.options.hidden) {
                this.toggleButton.addClass('coveo-hidden');
            }
            $(this.root).on('click', function (e) {
                //debugger;
                if (!_this.disabled && e.target != _this.element && Coveo.$(_this.element).find('.'+e.target.className).length == 0) {
                console.log(!_this.disabled);
                console.log(e.target != _this.element);
                console.log($(_this.element).find($(e.target)).length == 0);
                    _this.close();
                }
            });
            this.bind.onRootElement(Coveo.QueryEvents.querySuccess, function () {
                _this.setTopPosition();
                _this.setToggleHeight();
                _this.setToggleWidth();
            });
        }
        CustomFacetPopup.getMarkup = function () {
            return $("<div class='CoveoCustomFacetPopup'></div>");
        };
        CustomFacetPopup.prototype.setTitle = function (title) {
            this.logger.trace('Setting title', title);
            var toSet = $('<span></span>');
            if (_.isString(title)) {
                toSet.text(title);
            }
            else {
                toSet.append($(title));
            }
            this.buildTitle(toSet);
        };
        CustomFacetPopup.prototype.getTopPosition = function () {
            var header = $(this.root).find('.' + Coveo.Component.computeCssClassNameForType(Coveo.BoxHeader.ID));
            if (header.length != 0) {
                this.top = header.position().top + header.outerHeight();
            }
            else {
                this.top = 0;
            }
            return this.top;
        };
        CustomFacetPopup.prototype.setTopPosition = function () {
            this.top = this.getTopPosition();
        };
        CustomFacetPopup.prototype.setToggleHeight = function () {
            if (this.options.fullHeight) {
                this.popupWrapper.css({
                    'bottom': 0,
                    'top': $(this.element).offset().top + $(this.element).outerHeight() - 5,
                    'position': 'fixed',
                    'height': 'auto',
                    'max-height': 'inherit'
                });
            }
            else {
                this.popupWrapper.css({
                    'top': $(this.element).offset().top + $(this.element).outerHeight() - 5,
                    'position': 'fixed'
                });
            }
        };
        CustomFacetPopup.prototype.setToggleWidth = function () {
            if (this.options.fullWidth) {
                this.popupWrapper.css({
                    'right': 0,
                    'left': 0,
                    'position': 'fixed',
                    'width': 'auto',
                    'max-width': 'inherit'
                });
            }
        };
        CustomFacetPopup.prototype.open = function () {
            this.setTopPosition();
            this.setToggleWidth();
            this.setToggleHeight();
            $(this.element).trigger("onPopupOpen");
            this.logger.trace('Opening popup');
            this.isOpen = true;
            if (this.top == undefined) {
                this.setTopPosition();
            }
            this.setClasses();
            $(window).trigger('resize');
        };
        CustomFacetPopup.prototype.close = function () {
            this.logger.trace('Closing popup');
            this.isOpen = false;
            this.setClasses();
        };
        CustomFacetPopup.prototype.toggle = function () {
            this.isOpen = !this.isOpen;
            if (this.isOpen) {
                this.open();
            }
            else {
                this.close();
            }
        };
        CustomFacetPopup.prototype.setClasses = function () {
            $(this.element).toggleClass('coveo-opened', this.isOpen);
            if (this.options.withAnimation) {
                $(this.element).addClass('coveo-with-animation');
            }
        };
        CustomFacetPopup.prototype.buildTitle = function (title) {
            if (title === void 0) { title = this.buildBasicTitle(); }
            if (this.titleElement) {
                this.titleElement.remove();
            }
            this.titleElement = title
                .addClass('coveo-box-popup-title')
                .appendTo(this.toggleButton);
        };
        CustomFacetPopup.prototype.buildBasicTitle = function () {
            var element = $('<span></span>');
            var title = $('<span></span>').text(this.options.title).appendTo(element);
            if (this.options.icon !== undefined && this.options.icon != "") {
                $("<span></span>").addClass("coveo-icon").addClass(this.options.icon).prependTo(element);
            }
            return element;
        };
        CustomFacetPopup.prototype.buildToggleButton = function () {
            var _this = this;
            this.toggleButton = $('<div class="coveo-box-popup-toggle"></div>');
            this.buildTitle();
            $(this.element).prepend(this.toggleButton);
            this.toggleButton.click(function () { return _this.toggle(); });
        };
        CustomFacetPopup.ID = "CustomFacetPopup";
        CustomFacetPopup.options = {
            title: Coveo.ComponentOptions.buildStringOption({ defaultValue: 'Click here to open' }),
            icon: Coveo.ComponentOptions.buildIconOption(),
            withAnimation: Coveo.ComponentOptions.buildBooleanOption({ defaultValue: false }),
            fullWidth: Coveo.ComponentOptions.buildBooleanOption({ defaultValue: false }),
            fullHeight: Coveo.ComponentOptions.buildBooleanOption({ defaultValue: false }),
            hidden: Coveo.ComponentOptions.buildBooleanOption({ defaultValue: false })
        };
        return CustomFacetPopup;
    }(Coveo.Component));
    Coveo.CustomFacetPopup = CustomFacetPopup;
    Coveo.Initialization.registerAutoCreateComponent(CustomFacetPopup);




