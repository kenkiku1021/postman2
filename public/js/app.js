const AppInfo = {
    my_domain: "",

    fetch: function() {
        return m.request({
            method: "GET",
            url: "info",
        }).then(function(data) {
            AppInfo.my_domain = data.my_domain;
        }).catch(function(e) {
            alert("アプリケーション情報の取得に失敗しました。")
            console.log(e);
        });
    },
};

const User = {
    authorized: false,
    username: "",
    password: "",
    new_password: "",
    new_password_confirmation: "",
    forwarded: false,
    forward_address: "",
    loginError: false,
    
    fetch: function() {
        User.authorized = false;
        return m.request({
            method: "GET",
            url: "user",
        }).then(function(data) {
            User.authorized = true;
            User.username = data.username;
            User.forwarded = data.forwarded;
            User.forward_address = data.forward_address ? data.forward_address : "";
            User.password = "";
            User.new_password = "";
            User.new_password_confirmation = "";
        });
    },

    login: function() {
        User.authorized = false;
        const fd = new FormData();
        fd.append("username", User.username);
        fd.append("password", User.password);
        return m.request({
            method: "POST",
            url: "auth",
            body: fd,
        }).then(function(data) {
            User.username = data.username;
            User.forwarded = data.forwarded;
            User.forward_address = data.forward_address;
            User.authorized = true;
            User.password = "";
            User.new_password = "";
            User.new_password_confirmation = "";
        });
    },

    updatePassword: function() {
        const fd = new FormData();
        fd.append("current_password", User.password);
        fd.append("new_password", User.new_password);
        return m.request({
            method: "POST",
            url: "password",
            body: fd,
        }).then(function(data) {

        });
    },

    updateForward: function() {
        const fd = new FormData();
        fd.append("forwarded", User.forwarded) ? "true": "false";
        fd.append("forward_address", User.forward_address);
        return m.request({
            method: "POST",
            url: "forward",
            body: fd,
        }).then(function(data) {

        });
    },

    isValidPassword: function() {
        return User.password != "" && User.new_password != "" && User.new_password == User.new_password_confirmation;
    },

    isValidForward: function() {
        return (User.forwarded && User.forward_address != "") || !User.forwarded;
    },
};

const NavBar = {
    view: function(vnode) {
        return m("nav.navbar.navbar-expand-lg.navbar-dark.bg-dark", [
            m("a[href=#].navbar-brand", [
                "postman2 - ",
                AppInfo.my_domain,
            ]),
            m("button.navbar-toggler[data-toggle=collapse][data-target=navbar-content", [
                m("span.navbar-toggler-icon"),
            ]),
            m(".collapse.navbar-collapse#navbar-content", [
                User.authorized ? m(LogoutButton) : "",
            ]),
        ]);
    },
};

const LogoutButton = {
    view: function(vnode) {
        return m("form.form-inline.ml-auto[method=post][action=logout]", [
            m("input[type=submit].form-control.btn.btn-secondary.btn-sm", {
                value: "ログアウト",
            }),
        ]);
    },
};

const Main = {
    view: function(vnode) {
        return m("main.container", [
            vnode.children,
        ]);
    },
};

const LoginPage = {
    view: function(vnode) {
        return [
            m(NavBar),
            m(Main, [
                m("h2", "ログイン"),
                m("form", {
                    onsubmit: function(e) {
                        e.preventDefault();
                        User.login().then(function() {
                            m.route.set("/user");
                        }).catch(function(e) {
                            User.loginError = true;
                        });
                    }
                }, [
                    m(".form-group", [
                        m("label[for=username]", "メールアドレス"),
                        m(".input-group", [
                            m("input.form-control#username", {
                                value: User.username,
                                oninput: function(e) {
                                    User.username = e.target.value;
                                },
                            }),
                            m(".input-group-append", [
                                m("span.input-group-text", [
                                    "@",
                                    AppInfo.my_domain,
                                ]),
                            ]),
                        ]),
                    ]),
                    m(".form-group", [
                        m("label[for=password]", "パスワード") ,
                        m("input.form-control#password[type=password]", {
                            value: User.password,
                            oninput: function(e) {
                                User.password = e.target.value;
                            },
                        }),
                    ]),
                    m(".form-group.text-center", [
                        m("input[type=submit].btn.btn-primary", {
                            value: "ログイン",
                        }),
                    ]),
                ]),
                User.loginError ? m(".alert.alert-danger", [
                    "ユーザ名またはパスワードが正しくありません。",
                ]) : "",
            ]),
        ];
    },
};

const UserPage = {
    oninit: function(vnode) {
        if(!User.authorized) {
            User.fetch().then(function() {
                // authorized
            }).catch(function(e) {
                // not authorized
                m.route.set("/login");
            });
        }
    },

    view: function(vnode) {
        return [
            m(NavBar),
            m(Main, [
                m("h2", [
                    "メール設定 (",
                    User.username,
                    "@",
                    AppInfo.my_domain,
                    ")",
                ]),
                m(".row", [
                    m(".col-sm", [
                        m(".card", [
                            m("h5.card-header", [
                                "パスワード",
                            ]),
                            m(".card-body", [
                                m("form.password-form", [
                                    m(".form-group", [
                                        m("label[for=current_password", "現在のパスワード"),
                                        m("input[type=password].form-control#current_password", {
                                            value: User.password,
                                            oninput: function(e) {
                                                User.password = e.target.value;
                                            }
                                        }),
                                    ]),
                                    m(".form-group", [
                                        m("label[for=new_password]", "新しいパスワード"),
                                        m("input[type=password].form-control#new_password", {
                                            value: User.new_password,
                                            oninput: function(e) {
                                                User.new_password = e.target.value;
                                            },
                                        }),
                                    ]),
                                    m(".form-group", [
                                        m("label[for=new_password_confirmation]", "新しいパスワード（確認）"),
                                        m("input[type=password].form-control#new_password_confirmation", {
                                            value: User.new_password_confirmation,
                                            oninput: function(e) {
                                                User.new_password_confirmation = e.target.value;
                                            },
                                        }),
                                    ]),
                                ]),
                            ]),
                            m(".card-footer.text-center", [
                                m("button[type=button].btn.btn-primary", {
                                    disabled: !User.isValidPassword(),
                                    onclick: function(e) {
                                        User.updatePassword().then(function() {
                                            // password updated
                                            vnode.state.passwordUpdateError = null;
                                            alert("パスワードを更新しました。");
                                        }).catch(function(e) {
                                            vnode.state.passwordUpdateError = "パスワードの更新に失敗しました";
                                        });
                                    },
                                }, "更新"),
                            ]),
                        ]),
                        vnode.state.passwordUpdateError ? m(".alert.alert-danger", vnode.state.passwordUpdateError) : "",
                    ]),
                    m(".col-sm", [
                        m(".card", [
                            m("h5.card-header", "メール転送"),
                            m(".card-body", [
                                m(".form-group.form-check", [
                                    m("input[type=checkbox].form-check-input#forwarded", {
                                        checked: User.forwarded,
                                        onclick: function(e) {
                                            User.forwarded = e.target.checked;
                                        },
                                    }),
                                    m("label.form-check-label[for=forwarded]", "転送する"),
                                ]),
                                m(".form-group", [
                                    m("label[for=forward_address]", "転送先アドレス"),
                                    m("input.form-control#forward_address", {
                                        value: User.forward_address,
                                        disabled: !User.forwarded,
                                        oninput: function(e) {
                                            User.forward_address = e.target.value;
                                        },
                                    }),
                                ]),
                            ]),
                            m(".card-footer.text-center", [
                                m("button[type=button].btn.btn-primary", {
                                    disabled: !User.isValidForward(),
                                    onclick: function(e) {
                                        User.updateForward();
                                    },
                                }, "更新"),
                            ]),
                        ]),
                    ]),
                ]),
            ]),
        ];
    },
};

AppInfo.fetch();
m.route(document.body, "/user", {
    "/login": LoginPage,
    "/user": UserPage,
})