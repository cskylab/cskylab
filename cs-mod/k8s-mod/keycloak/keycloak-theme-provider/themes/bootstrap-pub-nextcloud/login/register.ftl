<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm'); section>
    <div class="clearFix"></div>
    <div class="container-fluid mx-auto bg-light pt-5">
        <div class="row justify-content-center">
            <#if section = "header">
                <div class="row justify-content-center">
                        <img src="${url.resourcesPath}/img/brand.svg" class="rounded mx-auto d-block" alt="brand_logo">
                        <span class="justify-content-center pl-2 text-muted mb-2 font-weight-normal" style="font-size: 22px;">${msg("registerTitle")}</span>
                </div>            
            <#elseif section = "form">
        </div>
        
         <div class="row justify-content-center">

            <div class="col-md-9 col-lg-6 col-xl-5 mx-auto border-right pr-5">


                <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">

                    <!-- Account Section -->
                    <div class="row mb-4 mt-2">
                        <span class="display-6">${msg("registerAccountSectionTitle")}</span>
                    </div>

                    <div class="form-group">
                        <input tabindex="1" id="firstName" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="firstName" value="${(register.formData.firstName!'')}" data-validate-field="firstName" type="text" placeholder="${msg("firstName")}" aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>"/>
                        <#if messagesPerField.existsError('firstName')>
                            <span id="input-error-firstname" class="text-danger float-right" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                            </span>
                        </#if>
                    </div>

                    <div class="form-group">
                        <input tabindex="2" id="lastName" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="lastName" value="${(register.formData.lastName!'')}" data-validate-field="lastName" type="text" placeholder="${msg("lastName")}" aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"/>
                        <#if messagesPerField.existsError('lastName')>
                            <span id="input-error-lastName" class="text-danger float-right" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                            </span>
                        </#if>
                    </div>

                    <div class="form-group">
                        <input tabindex="3" id="email" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="email" value="${(register.formData.email!'')}" data-validate-field="email" type="text" autocomplete="email" placeholder="${msg("email")}" aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"/>
                        <#if messagesPerField.existsError('email')>
                            <span id="input-error-email" class="text-danger float-right" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('email'))?no_esc}
                            </span>
                        </#if>
                    </div>


                    <#if !realm.registrationEmailAsUsername>
                        <div class="form-group">
                            <input tabindex="4" id="username" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="username" value="${(register.formData.username!'')}" data-validate-field="username" type="text" autocomplete="username" placeholder="${msg("username")}" aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"/>
                            <#if messagesPerField.existsError('username')>
                                <span id="input-error-username" class="text-danger float-right" aria-live="polite">
                                    ${kcSanitize(messagesPerField.get('username'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </#if>

                    <#if passwordRequired??>
                        <div class="form-group mt-3 mb-3">
                            <input tabindex="5" id="password" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="password" data-validate-field="password" type="password" autocomplete="new-password" placeholder="${msg("password")}" />
                            <#if messagesPerField.existsError('username')>
                                <span id="input-error-password" class="text-danger float-right" aria-live="polite">
                                    ${kcSanitize(messagesPerField.get('password'))?no_esc}
                                </span>
                            </#if>
                        </div>

                        <div class="form-group pb-5">
                            <input tabindex="6" id="password-confirm" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="password-confirm" data-validate-field="password_confirm" type="password" placeholder="${msg("passwordConfirm")}" />
                            <#if messagesPerField.existsError('password-confirm')>
                                <span id="input-error-password-confirm" class="text-danger float-right" aria-live="polite">
                                    ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </#if>
                    <#if recaptchaRequired??>
                        <div class="form-group">
                            <div class="${properties.kcInputWrapperClass!}">
                                <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                            </div>
                        </div>
                    </#if>

                    <div id="kc-form-buttons" class="form-group mt-5 mb-5">
                        <button tabindex="24" class="btn btn-primary btn-block text-uppercase mb-2 rounded-pill shadow-sm" name="login" id="kc-login" type="submit">${msg("doRegister")}</button>
                        <a class="mt-1 float-right" href="${url.loginUrl}">${kcSanitize(msg("backToLogin"))?no_esc}</a>
                    </div>
                </form>

            </div>
         </div>
       

        
    </#if>
    </div>
</@layout.registrationLayout>

<script>

    var defaultValLen = {
        minLength: parseInt("${msg("minLengthField")}"),
        maxLength: parseInt("${msg("maxLengthField")}"),
    };    

    var defaultValDef = {
        required: true,
        minLength: defaultValLen.minLength,
        maxLength: defaultValLen.maxLength,
    };    

    var defaultLenMsg = {
        minLength: String("${msg("minLengthFieldMessage")}").replace('*', defaultValDef.minLength),
        maxLength: String("${msg("maxLengthFieldMessage")}").replace('*', defaultValDef.maxLength),        
    }

    var defaultValMsg = {
        minLength: defaultLenMsg.minLength,
        maxLength: defaultLenMsg.maxLength,
        required: "${msg("isRequieredField")}"      
    }

    new window.JustValidate('#kc-register-form', {
        rules: {
            firstName: defaultValDef,
            lastName: defaultValDef,
            email: {
                required: true,
                email: true
            },
            username: defaultValDef,
            password: {
                required: true,
                strength: {
                    default: true
                }                
            },
            password_confirm: {
                required: true
            },
        },
        messages: {
            firstName: defaultValMsg,
            lastName: defaultValMsg,
            username: defaultValMsg,
            password: "${msg("passwordRequirement")}",
        },
        focusWrongField: true
    });


</script>