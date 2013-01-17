
// Lightbox.js
// Author: Tanzeel R.A. Kazi
// This module is a prototype UI.Window wrapper to easily enable creating and handling lightbox popups.

(function () {
    var moduleName = "Lightbox";
    if (moduleName in window)
    {
        return;
    }
    
    var Lightbox = function (options) {
        this._constructor(options);
        return;
    };
    
    Lightbox.type = {
        NONE: 1,
        ALERT: 2,
        CONFIRM: 3
    };
    
    Lightbox.defaultOptions = {
        id: null,
        theme: "lightbox",
        resizable: false,
        width: 300,
        height: 150,
        center: true,
        focus: true,
        show: true,
        title: null,
        content: null,
        type: Lightbox.type.NONE,
        callback: null,
        callbackContext: null,
        closeOnNextPopup: false
    };
    
    Lightbox.iNextAutoId = 1;
    
    Lightbox.list = [];
    Lightbox.listIndex = {};
    
    Lightbox.popupToCloseOnNextPopup = null;
    
    Lightbox.add = function (lightbox) {
        if (!(lightbox instanceof Lightbox)) {
            return;
        }
        this.listIndex[lightbox.id] = this.list.length;
        this.list.push(lightbox);
    };
    
    
    Lightbox.remove = function (lightbox) {
        
        if (lightbox instanceof String) {
            lightbox = this.findById(lightbox);
        }
        
        if (!(lightbox instanceof Lightbox)) {
            return;
        }
        
        this.list[this.listIndex[lightbox.id]] = null;
        delete this.listIndex[lightbox.id];
        
    };
    
    Lightbox.findById = function (lightboxId) {
        var lightbox = null;
        if (lightboxId in this.listIndex) {
            lightbox = this.list[this.listIndex[lightboxId]];
        }
        return lightbox;
    };
    
    Lightbox.close = function (lightboxId, callbackData) {
        callbackData = callbackData || null;
        var lightbox = this.findById(lightboxId);
        if (lightbox === null) {
            return;
        }
        lightbox.close(callbackData);
        return;
    };
    
    Lightbox.flash = function (key, message) {
        var title = '<span style="text-transform: capitalize;">' + key + '</span>';
        var content = '<div style="padding: 5px 15px;">' +
                      message +
                      '</div>';
        
        var lightboxConfig = {
            type: Lightbox.type.ALERT,
            title: title,
            content: content
        };
        var lightbox = new Lightbox(lightboxConfig);
        return lightbox;
    };
    
    
    Lightbox.prototype.id = null;
    Lightbox.prototype.config = null;
    Lightbox.prototype.handle = null;
    
    Lightbox.prototype._constructor = function (options) {
        
        var config = Object.extend({}, Lightbox.defaultOptions);
        Object.extend(config, options);
        this.config = config;
        
        if (config.id === null) {
            config.id = "lightbox" + (Lightbox.iNextAutoId++);
        }
        
        this.id = config.id;
        
        var btnHtml = '';
        
        switch (config.type) {
            case Lightbox.type.ALERT:
                config.title = (typeof config.title === "string") ? config.title : 'Message';
                btnHtml = '<div class="buttons_container">' +
                          '<input type="button" class="button" onclick="' + moduleName + '.close(\'' + this.config.id.replace("'", "\\'") + '\')" value="OK" />' +
                          '</div>';
                config.content += btnHtml;
                break;
                
            case Lightbox.type.CONFIRM:
                config.title = (typeof config.title === "string") ? config.title : 'Confirmation';
                btnHtml = '<div class="buttons_container">' +
                          '<input type="button" class="button" onclick="' + moduleName + '.close(\'' + this.config.id.replace("'", "\\'") + '\', true)" value="OK" />' +
                          '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
                          '<input type="button" class="button" onclick="' + moduleName + '.close(\'' + this.config.id.replace("'", "\\'") + '\', false)" value="Cancel" />' +
                          '</div>';
                config.content += btnHtml;
                break;
            
            default:
                break;
        }
        
        var popupToCloseOnNextPopup = Lightbox.popupToCloseOnNextPopup;
        
        if (popupToCloseOnNextPopup !== null) {
            popupToCloseOnNextPopup.close();
            popupToCloseOnNextPopup = null;
        }
        
        if (config.closeOnNextPopup) {
            popupToCloseOnNextPopup = this;
        }
        
        Lightbox.popupToCloseOnNextPopup = popupToCloseOnNextPopup;
        
        var lightboxConfig = {
            theme: config.theme,
            resizable: config.resizable,
            width: config.width,
            height: config.height,
            close: false
        };
        
        var lightbox = new UI.Window(lightboxConfig);
        this.handle = lightbox;
        
        Lightbox.add(this);
        
        lightbox.setContent(config.content);
        if (typeof config.title === "string") {
            lightbox.setHeader(config.title);
        }
        
        lightbox.show(config.show);
        
        if (config.show) {
            if (config.focus) {
                lightbox.focus();
            }
            
            if (config.center) {
                lightbox.center();
            }
        }
        
        return;
    };
    
    Lightbox.prototype.close = function (callbackData) {
        
        callbackData = callbackData || null;
        if (!(callbackData instanceof Array)) {
            callbackData = [callbackData];
        }
        
        this.handle.destroy();
        Lightbox.remove(this);
        
        if (typeof(this.config.callback) === "function") {
            var callbackContext = this.config.callbackContext || window;
            this.config.callback.apply(callbackContext, callbackData);
        }
        return;
    };
    
    window[moduleName] = Lightbox;
    
    return;
})();
