Pod::Spec.new do |s|
  s.name             = 'BottomSheetPresenter'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BottomSheetPresenter.'

  s.homepage         = 'https://github.com/raulmax319/BottomSheetPresenter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Raul Max' => 'raulmax319@gmail.com' }
  s.source           = { :git => 'https://github.com/raulmax319/BottomSheetPresenter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.default_subspec = 'Release'

  s.subspec 'Release' do |release|
    release.vendored_frameworks = 'BottomSheetPresenter.xcframework'
  end

  s.subspec 'Debug' do |debug|
    debug.source_files = 'BottomSheetPresenter/**/*'

    debug.test_spec do |test_spec|
      test_spec.source_files = 'BottomSheetPresenter/Tests/**/*'
    end
  end
end
