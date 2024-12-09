# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Pod::Spec.new do |s|
    s.name         = 'RecaptchaEnterprise'
    s.version      = '18.7.0-beta01'
    s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }
    s.authors      = 'Google, Inc.'
    s.homepage     = 'https://cloud.google.com/recaptcha-enterprise'
    s.summary      = 'RecaptchaEnterprise solution podspec for iOS'

    s.source       = { 
        :git => 'https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk.git', 
        :tag => 'CocoaPods-' + s.version.to_s
    }

    s.source_files = 'Sources/RecaptchaEnterprise/*.swift'
    s.static_framework = true
    s.dependency 'RecaptchaInterop', '~> 101.0.0'
    s.dependency 'RecaptchaEnterpriseSDK', s.version.to_s
  end
