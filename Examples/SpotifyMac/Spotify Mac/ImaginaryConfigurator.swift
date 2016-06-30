import Imaginary

struct ImaginaryConfigurator: Configurator {

  func configure() {
    Imaginary.Configuration.preConfigure = nil
    Imaginary.Configuration.postConfigure = nil
    Imaginary.Configuration.transitionClosure = { imageView, image in
      imageView.image = image
    }
  }
}
