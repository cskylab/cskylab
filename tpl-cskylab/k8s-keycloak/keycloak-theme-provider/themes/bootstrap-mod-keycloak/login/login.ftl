<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "form">
        <#if realm.password>
    	<div class="container-fluid">
            <div class="row d-flex justify-content-center">
                <!-- Left half -->
                <div class="col-md-5 col-lg-5 col-xl-4 d-none d-md-flex">
                    <div class="app-name d-flex align-items-center mt-5">
                        <div class="container pl-5 mt-5">
                            <div class="row mt-5">
                                <div class="mx-auto">
                                    <h1 class="display-4">${msg("applicationName")}</h1>
                                    <p class="text-muted mb-3">${msg("applicationDescription")}</p>
                                </div>
                            </div>
                            <div class="row">
                                <div class="text-left">
                                    <p>${msg("poweredByLabel")}&nbsp;
                                        <a href="${msg('poweredByUrl')}" class="font-italic text-muted "> 
                                            <u>${msg("poweredByBrand")}</u>
                                        </a>
                                    </p>                                    
                                </div>  
                            </div>
                        </div>
                    </div>
                </div>


                <!-- Right half -->
                <div class="col-md-7 col-lg-6 col-xl-5 bg-light">
                    <div class="login d-flex align-items-center py-5">

                        <div class="container">
                                <div id="login-brand-container" class="col-lg-10 col-xl-9 mx-auto align-items-top">
                                    <div style="min-height: 210px;">
                                        <img id="brand-logo" src="${url.resourcesPath}/img/brand.svg" class="rounded mx-auto d-block" alt="cskylab">
                                        <p class="text-center text-muted mb-4 pl-2" >${msg("loginIntroText")}</p>
                                    </div>
                                    <h1 class="text-center display-4 mb-5 d-md-none">${msg("applicationName")}</h1>
                                    <#if message?has_content>
                                        <div id="login-alert" class="alert alert-danger col-sm-12">
                                            <span class="kc-feedback-text">${kcSanitize(message.summary)?no_esc}</span>
                                        </div>
                                    </#if>                                                                    


                                    <form id="kc-form-login" class="${properties.kcFormClass!}" onsubmit="login.disabled = true; return true;" action="${url.loginAction?keep_after('^[^#]*?://.*?[^/]*', 'r')}" method="post">
                                        
                                        <div class="form-group mb-3">
                                            <#if usernameEditDisabled??>
                                                <input tabindex="1" id="username" class="form-control rounded-pill border-0 shadow-sm px-4" name="username" value="${(login.username!'')}" type="text" disabled placeholder="<#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>"/>
                                            <#else>
                                                <input tabindex="1" id="username" class="form-control rounded-pill border-0 shadow-sm px-4" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="off" placeholder="<#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>" />
                                            </#if>                                            
                                        </div>

                                        <div class="form-group mb-3">
                                            <input tabindex="2" id="password" class="form-control rounded-pill border-0 shadow-sm px-4 text-primary" name="password" type="password" autocomplete="off" placeholder="${msg("password")}"/>
                                        </div>


                                        <#if realm.rememberMe && !usernameEditDisabled??>
                                            <div class="form-check mb-5 ml-1 mt-4">
                                                <#if login.rememberMe??>
                                                    <input tabindex="3" id="rememberMe" name="rememberMe" class="form-check-input" type="checkbox" tabindex="3" checked> 
                                                    <label for="rememberMe" class="form-check-label">${msg("rememberMe")}</label>
                                                <#else>
                                                    <input tabindex="3" id="rememberMe" name="rememberMe" class="form-check-input" type="checkbox" tabindex="3"> 
                                                    <label for="rememberMe" class="form-check-label">${msg("rememberMe")}</label>
                                                </#if>
                                            </div>
                                        </#if>

                                        <div class="form-group mb-3 d-block">
                                            <button tabindex="4" class="btn btn-primary btn-block mb-2 rounded-pill shadow-sm" name="login" id="kc-login" type="submit">${msg("doLogIn")}</button>
                                            <#if realm.resetPasswordAllowed>
                                                <div class="text-right my-2 notice">
                                                    <a href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                                                </div>
                                            </#if>
                                            <#if realm.password && social.providers??>
                                                <#list social.providers as p>
                                                    <a href="${p.loginUrl}" id="zocial-${p.alias}" class="btn btn-primary">${msg("doLogIn")} With ${p.displayName}</a>
                                                </#list>
                                            </#if>
                                        </div>

                                        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                                        <div class="form-group  pt-3 mt-5 border-top">
                                            <span>${msg("noAccount")}</span>
                                        </div>
                                        </#if>

                                        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                                            <div class="row f-flex justify-content-center mt-4 border-bottom">
                                                <div class="col-12 mb-5 btn btn-success btn-block rounded-pill shadow-sm py-3">
                                                    <a class="text-uppercase text-white" href="${url.registrationUrl}" name="create-account" id="kc-create-account">${msg("doCreateAccount")}</a>
                                                </div>
                                            </div>
                                        </#if>                                         

                                    </form>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
	    </div>




</#if>
</#if>
</@layout.registrationLayout>