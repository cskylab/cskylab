<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayMessage=false; section>
    <#if section = "title">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
    <div class="container-fluid">
        <div class="row justify-content-center">

                <div class="col-md-12 bg-light">
                    <div class="login d-flex align-items-center py-5">

                        <div class="container">
                                <div id="login-brand-container" class="col-lg-9 col-xl-6 mx-auto align-items-top">
                                    <div style="min-height: 210px;">
                                        <img id="brand-logo" src="${url.resourcesPath}/img/brand.svg" class="rounded mx-auto d-block" alt="brand">
                                        <p class="text-center text-muted mb-4 pl-2" >${msg("resetPasswordLabel")}</p>
                                    </div>
                                    <#if message?has_content>
                                        <div id="login-alert" class="alert alert-danger col-sm-12">
                                            <span class="kc-feedback-text">${message.summary!''}</span>
                                        </div>
                                    </#if>
                                    <div id="login-warn" class="alert alert-warning col-sm-12 mb-3">
                                        <span class="kc-feedback-text">${msg("emailInstruction")}</span>
                                    </div>
                                    
                                    <form id="kc-reset-password-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                                        <div class="${properties.kcInputWrapperClass!} mb-3">
                                            <span class="input-group-addon"><i class="glyphicon glyphicon-envelope"></i></span>
                                             <input type="text" id="username" name="username" class="form-control rounded-pill border-0 shadow-sm px-4" autofocus  
                                                placeholder="<#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>"/>
                                        </div>
                        
                                        <div id="kc-form-buttons" style="margin-top:10px" class="${properties.kcFormButtonsClass!}">
                                            <div class="${properties.kcFormButtonsWrapperClass!}">
                                                <button class="btn btn-primary btn-block text-uppercase mb-3 rounded-pill shadow-sm" type="submit">${msg("doSubmit")}</button>
                                                <p style="float:right; font-size: 90%; position: relative; "><a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a></p>
                                            </div>
                                        </div>
                                    </form>                                    
                                </div>
                            </div>
                        </div>
                    </div>
                </div>            
        </div>
    </div>

    <#elseif section = "info" >
    </#if>
</@layout.registrationLayout>
