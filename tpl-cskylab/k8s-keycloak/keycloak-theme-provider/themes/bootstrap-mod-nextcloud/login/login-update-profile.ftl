<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','email','firstName','lastName'); section>
    <div class="clearFix"></div>
    <div class="container-fluid mx-auto bg-light pt-5">
        <div class="row justify-content-center">
        <#if section = "header">
            <div class="row justify-content-center">
                <img src="${url.resourcesPath}/img/brand.svg" class="rounded mx-auto d-block" alt="brand_logo">
                <span class="justify-content-center pl-2 text-muted mb-2 font-weight-normal" style="font-size: 22px;">${msg("updateProfileTitle")}</span>
            </div> 
        <#elseif section = "form">
        </div>
        
         <div class="row justify-content-center">

            <div class="col-md-9 col-lg-6 col-xl-5 mx-auto border-right pr-5">


                <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">

                    <!-- Account Section -->
                    <div class="row mb-4 mt-1">
                        <span class="display-6">${msg("registerAccountSectionTitle")}</span>
                    </div>

                    <div class="form-group">
                        <input tabindex="1" id="firstName" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="firstName" value="${(user.firstName!'')}" data-validate-field="firstName" type="text" placeholder="${msg("firstName")}" aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>"/>
                        <#if messagesPerField.existsError('firstName')>
                            <span id="input-error-firstname" class="text-danger float-right" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                            </span>
                        </#if>
                    </div>

                    <div class="form-group">
                        <input tabindex="2" id="lastName" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="lastName" value="${(user.lastName!'')}" data-validate-field="lastName" type="text" placeholder="${msg("lastName")}" aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"/>
                        <#if messagesPerField.existsError('lastName')>
                            <span id="input-error-lastName" class="text-danger float-right" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                            </span>
                        </#if>
                    </div>

                    <div class="form-group">
                        <input tabindex="3" id="email" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="email" value="${(user.email!'')}" data-validate-field="email" type="text" autocomplete="email" placeholder="${msg("email")}" aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"/>
                        <#if messagesPerField.existsError('email')>
                            <span id="input-error-email" class="text-danger float-right" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('email'))?no_esc}
                            </span>
                        </#if>
                    </div>                    

                    <#if user.editUsernameAllowed>
                        <div class="form-group">
                            <input tabindex="4" id="username" class="form-control rounded-pill border-0 shadow-sm px-4 mb-1" name="username" value="${(user.username!'')}" data-validate-field="username" type="text" autocomplete="username" placeholder="${msg("username")}" aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"/>
                            <#if messagesPerField.existsError('username')>
                                <span id="input-error-username" class="text-danger float-right" aria-live="polite">
                                    ${kcSanitize(messagesPerField.get('username'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </#if>

                    <div id="kc-form-buttons" class="form-group mt-5 mb-5">
                        <div class="row justify-content-center">
                            <input tabindex="24" class="btn btn-success btn-block mb-2 rounded-pill shadow-sm col-4" name="submit-ara" type="submit" value="${msg("doSubmit")}" />
                        </div>
                    </div>

                </form>
            </div>
         </div>

            </#if>
        </div>
</@layout.registrationLayout>
    
<script>

    new window.JustValidate('#kc-register-form', {
        rules: {
            firstName: {
                required: true,
                maxLength: 20
            },
            lastName: {
                required: true,
                maxLength: 20
            },
            email: {
                required: true,
                email: true
            },
            username: {
                required: true,
                maxLength: 20
            },
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
            password: "${msg("passwordRequirement")}",
        },
        focusWrongField: true
    });

    

</script>