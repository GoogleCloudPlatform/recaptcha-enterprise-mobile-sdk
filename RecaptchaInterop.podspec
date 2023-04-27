Pod::Spec.new do |s|
  s.name             = 'RecaptchaInterop'
  s.version          = '18.2.0'
  s.summary          = 'Interfaces that allow Firebase SDKs to use RecaptchaEnterprise functionality.'

  s.description      = <<-DESC
  Not for public use.
  A set of protocols that Firebase SDKs can use to interoperate with RecaptchaEnterprise in a safe
  and reliable manner.
                       DESC

  s.homepage         = 'https://cloud.google.com/recaptcha-enterprise'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Google, Inc.'

  # NOTE that these should not be used externally, this is for Firebase pods to depend on
  # RecaptchaEnterprise.
  s.source           = {
    :git => 'https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk.git',
    :tag => 'CocoaPods-' + s.version.to_s
  }
  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/Interop/*.[hm]'
  s.public_header_files = 'Sources/Interop/*.h'
end