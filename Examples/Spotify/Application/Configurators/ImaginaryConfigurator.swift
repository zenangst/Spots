import Imaginary

struct ImaginaryConfigurator: Configurator {

  static func configure() {
    Imaginary.preConfigure = { imageView in
      imageView.alpha = 0.0
    }

    Imaginary.postConfigure = { imageView in
      UIView.animateWithDuration(0.3) {
        imageView.alpha = 1.0
      }
    }
  }
}
