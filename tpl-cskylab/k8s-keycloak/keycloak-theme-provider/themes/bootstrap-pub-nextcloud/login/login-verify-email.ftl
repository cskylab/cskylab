<#import "template.ftl" as layout>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12 bg-light">
                <div class="login d-flex align-items-center">
                    <div class="container d-flex justify-content-center text-center">
                        <@layout.registrationLayout displayInfo=true; section>
                            <#if section = "header">
                                <div class="col-lg-9 col-xl-6 mx-auto align-items-top">
                                    <div style="min-height: 210px;">
                                        <img id="brand-logo" src="${url.resourcesPath}/img/brand.svg" class="rounded mx-auto d-block" alt="brand">
                                        <span class="text-muted mb-2 font-weight-normal" style="font-size: 18px;">${msg("emailVerifyTitle")}</span>
                                    </div>
                                </div>
                            <#elseif section = "form">
                                <div id="login-warn" class="alert alert-warning d-flex justify-content-center pt-3 pl-2">
                                    <span class="kc-feedback-text">${msg("emailVerifyInstruction1")}</span>
                                </div>    
                            <#elseif section = "info">
                                <div id="login-warn" class="alert alert-secondary d-flex justify-content-center pt-3">
                                    <div id="kc-form-light" class="col-12">
                                        <p class="kc-feedback-text justify-content-center">${msg("emailVerifyInstruction2")}</p>
                                        <a class="btn btn-primary btn-block mb-3 rounded-pill shadow-sm"  href="${url.loginAction}">${msg("doClickHere")}&nbsp;${msg("emailVerifyInstruction3")}</a>
                                    </div>
                                </div>    
                            </#if>
                        </@layout.registrationLayout>
                    </div>
                </div>
            </div>
        </div>
    </div>