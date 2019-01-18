"use strict";

/*
 * // _config/path/to/page.js
 * window.config = {
 *   path: "path/to/page.html",
 *   page: "Path.To.Page",
 * }
 */

try {
  var Error = (function(){
    // clone "error" node at head of script
    // because all body nodes remove in Elm.init process
    var node = document.getElementById("error").cloneNode(true);
    node.classList.remove("display-none");

    var showError = function(){
      document.body.replaceWith(node);
    };

    return {
      show: function(){
        showError();
      },
    };
  })();

  var Detect = (function(config){
    var current_path = config.path;

    var redirect = function(){
      GettoDetect({
        version_to_path: function(version){
          return "/"+version+"/"+current_path+location.search;
        }
      }).from_current_version(version,function(path) {
        location.href = path;
      });
    };

    return {
      redirect: function(){
        redirect();
      },
    };
  })(config);

  var Auth = (function(){
    var keycloak = Keycloak({
      url: document.getElementById("keycloak").src.replace("/js/keycloak.js",""),
      realm: "getto",
      clientId: "upload",
    });

    var updateTokenConfig = {
      interval: 2 * 60 * 1000,
      scope: 2 * 60 + 30,
    };

    var init = function(callback){
      keycloak.init({
        onLoad: "login-required",
        checkLoginIframe: false,
      })
        .success(function(){
          callback(keycloak.token);
        })
        .error(Error.show);
    };

    var updateToken = function(callback){
      keycloak.updateToken(updateTokenConfig.scope)
        .success(function(refreshed) {
          if (refreshed) {
            callback(keycloak.token);
          }
        })
        .error(function() {
          keycloak.clearToken();
        });
    };

    var logout = function(){
      keycloak.logout();
    };

    return {
      /**
       * callback: function(token){
       *   token // access token
       * }
       */
      init: function(callback){
        init(callback);
      },

      /**
       * callback: function(token){
       *   token // access token
       * }
       */
      setUpdateTokenInterval: function(callback){
        setTimeout(function(){ updateToken(callback); }, 0);
        setInterval(function(){ updateToken(callback); }, updateTokenConfig.interval);
      },

      logout: function(){
        logout();
      },
    };
  })();

  var Storage = (function(config){
    var current_path = config.path;
    var key = "app";

    var allStorage = function(){
      return JSON.parse(localStorage.getItem(key));
    };

    var toValue = function(value){
      if (value === null) {
        return {
          global: null,
          local:  null,
        };
      } else {
        return {
          global: value._global,
          local:  value[current_path],
        };
      }
    };

    var update = function(value){
      if (value === null) {
        localStorage.removeItem(key);
      } else {
        var all = allStorage();

        all.global        = value.global;
        all[current_path] = value.local;

        localStorage.setItem(key, JSON.stringify(all));
      }
    };

    return {
      /**
       * returns: { global: obj, local: obj }
       */
      load: function(){
        return toValue(allStorage());
      },

      /**
       * callback: function(value){
       *   value // { global: obj, local: obj }
       * }
       */
      addChangedListener: function(callback){
        window.addEventListener("storage", function(event) {
          if (event.storageArea === localStorage && event.key === key) {
            callback(toValue(event.newValue));
          }
        }, false);
      },

      /**
       * value: { global: obj, local: obj }
       */
      store: function(value){
        update(value);
      },
    };
  })(config);

  var ElmPorts = (function(config){
    return {
      init: function(app){
        return {
          subscribe: function(name,func) {
            if (app.ports && app.ports[name]) {
              app.ports[name].subscribe(func);
            }
          },

          send: function(name,data) {
            if (app.ports && app.ports[name]) {
              app.ports[name].send(data);
            }
          },
        };
      },
    };
  })(config);



  // main entry point
  Auth.init(function(token){
    try {
      var ports = ElmPorts.init((function(){
        return config.page.split(".")
          .reduce(function(acc,m){return acc[m];},Elm.GettoUpload.App).EntryPoint
          .init({
            flags: {
              token:   token,
              storage: Storage.load(),
              project: {
                name:     document.getElementById("project").innerText,
                company:  document.getElementById("company").innerText,
                title:    document.getElementById("title").innerText,
                subTitle: document.getElementById("sub-title").innerText,
              },
            },
          });
      })());

      var onTokenChanged = function(token){
        // token: "access token"
        ports.send("onTokenChanged",token);
      };

      var onStorageChanged = function(value) {
        // value: { global: obj, local: obj }
        ports.send("onStorageChanged",value);
      };

      ports.subscribe("detectNewVersion", function(_params){
        Detect.redirect();
      });

      Auth.setUpdateTokenInterval(function(token){
        onTokenChanged(token);
      });

      ports.subscribe("logout", function(_params){
        Auth.logout();
      });

      // value: { global: obj, local: obj }
      ports.subscribe("store", function(value) {
        Storage.store(value);
        setTimeout(function(){ onStorageChanged(value); }, 0);
      });

      Storage.addChangedListener(function(value){
        onStorageChanged(value);
      });

      ports.subscribe("fixedMidashi", function(_params) {
        setTimeout(function(){
          FixedMidashi.create();
        },300);
      });

    } catch(e) {
      Error.show();
      throw e;
    }
  });
} catch(e) {
  Error.show();
  throw e;
}
