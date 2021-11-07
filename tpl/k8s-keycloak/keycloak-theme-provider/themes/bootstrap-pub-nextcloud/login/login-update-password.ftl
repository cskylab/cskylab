<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm'); section>
    <div class="clearFix"></div>
    <div class="container-fluid mx-auto bg-light pt-5">
        <div class="row justify-content-center">
        <#if section = "header">
            <div class="row justify-content-center">
                <img src="${url.resourcesPath}/img/brand.svg" class="rounded mx-auto d-block" alt="brand_logo">
                <span class="justify-content-center pl-2 text-muted mb-2 font-weight-normal" style="font-size: 22px;">${msg("updatePasswordTitle")}</span>
            </div>      
        <#elseif section = "form">
        </div>
        <div class="row justify-content-center">
            <div class="col-md-9 col-lg-6 col-xl-5 mx-auto border-right pr-5">
                
                <form id="kc-passwd-update-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                    <input type="text" id="username" name="username" value="${username}" autocomplete="username" readonly="readonly" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" style="display:none;" placeholder="${msg("passwordNew")}"/>
                    <input type="password" id="password" name="password" autocomplete="current-password" style="display:none;" placeholder="${msg("passwordNew")}" />

                    <div class="${properties.kcFormGroupClass!}">
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password-new" class="${properties.kcLabelClass!}">${msg("passwordNew")}</label>
                        </div>
                        <div class="${properties.kcInputWrapperClass!}">
                            <input type="password" id="password-new" name="password-new" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" autofocus autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>" placeholder="${msg("passwordNew")}" />
                            <#if messagesPerField.existsError('password')>
                                <span id="input-error-password" class="text-danger float-right" aria-live="polite">
                                    ${kcSanitize(messagesPerField.get('password'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </div>

                    <div class="mb-4 ${properties.kcFormGroupClass!}">
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password-confirm" class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                        </div>
                        <div class="${properties.kcInputWrapperClass!}">
                            <input type="password" id="password-confirm" name="password-confirm" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>" placeholder="${msg("passwordConfirm")}" />
                            <#if messagesPerField.existsError('password-confirm')>
                                <span id="input-error-password-confirm" class="text-danger float-right" aria-live="polite">
                                    ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </div>

                    <div class="${properties.kcFormGroupClass!}">
                        <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                            <div class="${properties.kcFormOptionsWrapperClass!}">
                                <#if isAppInitiatedAction??>
                                    <div class="checkbox">
                                        <label><input type="checkbox" id="logout-sessions" name="logout-sessions" value="on" checked> ${msg("logoutOtherSessions")}</label>
                                    </div>
                                </#if>
                            </div>
                        </div>

                        <div id="kc-form-buttons" class="mt-4 ${properties.kcFormButtonsClass!}">
                            <#if isAppInitiatedAction??>
                                <input class="btn btn-success btn-block text-uppercase mb-3 rounded-pill shadow-sm" type="submit" value="${msg("doSubmit")}" />
                                <button class="btn btn-secondary btn-block text-uppercase mb-3 rounded-pill shadow-sm" type="submit" name="cancel-aia" value="true" />${msg("doCancel")}</button>
                            <#else>
                                <input class="btn btn-success btn-block text-uppercase mb-3 rounded-pill shadow-sm" type="submit" value="${msg("doSubmit")}" />
                            </#if>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        </#if>
    </div>
</@layout.registrationLayout>

