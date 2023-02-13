class Profile {
  String? name;
  String? pin;
  

  Profile(
      {this.name,
      this.pin});

  @override
  String toString() {
    return "{name: $name, pin: $pin }";
  }
}
