

pub enum Civilizations: UInt8 {
  pub case Chinese
  pub case Roman
  pub case Egyptian
}

pub fun main(): UInt8{
  return Civilizations.Roman.rawValue;
}