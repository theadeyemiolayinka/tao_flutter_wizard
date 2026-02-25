{{#include_local}}
abstract interface class {{entity_name.pascalCase()}}LocalDataSource {
  Future<{{entity_name.pascalCase()}}Model?> getCached{{entity_name.pascalCase()}}(String id);
  Future<void> cache{{entity_name.pascalCase()}}({{entity_name.pascalCase()}}Model model);
  Future<void> clearCache();
}

class {{entity_name.pascalCase()}}LocalDataSourceImpl
    implements {{entity_name.pascalCase()}}LocalDataSource {
  // TODO: inject your local storage (e.g. Hive box, SharedPreferences, etc.)

  @override
  Future<{{entity_name.pascalCase()}}Model?> getCached{{entity_name.pascalCase()}}(String id) async {
    // TODO: impl
    return null;
  }

  @override
  Future<void> cache{{entity_name.pascalCase()}}({{entity_name.pascalCase()}}Model model) async {
    // TODO: impl
  }

  @override
  Future<void> clearCache() async {
    // TODO: impl
  }
}
{{/include_local}}
{{^include_local}}
// Local datasource not requested. Re-run the datasource brick with include_local: true to generate it.
{{/include_local}}
