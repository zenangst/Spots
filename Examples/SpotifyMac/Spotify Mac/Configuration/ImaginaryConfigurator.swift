import Imaginary

struct ImaginaryConfigurator: Configurator {

  func configure() {
    Imaginary.Configuration.preConfigure = nil
    Imaginary.Configuration.postConfigure = nil

    Imaginary.Configuration.transitionClosure = { imageView, image in
      imageView.image = image
      imageView.layer?.opacity = 1.0
      let animation = CABasicAnimation(keyPath: "opacity")
      animation.duration = 0.3
      animation.fromValue = 0.0
      animation.toValue = 1.0
      imageView.layer?.add(animation, forKey: "fade")
    }
  }
}
