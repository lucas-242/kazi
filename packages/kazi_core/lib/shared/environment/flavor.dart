enum Flavor {
  staging('staging'),
  prod('prod'),
  prodTest('prod_test');

  const Flavor(this.value);

  final String value;

  static Flavor? fromString(String value) {
    for (Flavor environment in Flavor.values) {
      if (environment.value == value) {
        return environment;
      }
    }

    return null;
  }
}
