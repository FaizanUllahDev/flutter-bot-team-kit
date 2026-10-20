# Generic templates (adapt names)

## Network service (prefer FeatureNetworkCaller)

`FeatureNetworkCaller` decodes JSON to a `Map`. Pass `Model.fromJson`, no string `*FromJson` helpers.

```dart
class FeatureNetworkService {
  Future<FeatureModel> fetchData(String id) async {
    if (AppUtil.isMockTesting) {
      return FeatureMockData.getPayload();
    }

    return FeatureNetworkCaller.postEncrypted<FeatureModel>(
      urlWithEndpoint: UrlConstants.featureResolve,
      data: {'id': id},
      isGeoCodeRequired: false,
      loggerTag: 'FeatureResolve',
      parse: FeatureModel.fromJson,
    );
  }
}
```

## UseCase (verb + noun)

```dart
class FetchFeatureUseCase {
  FetchFeatureUseCase(this._networkService);
  final FeatureNetworkService _networkService;

  Future<FeatureModel> call(String id, {bool forceRefresh = false}) async {
    return _networkService.fetchData(id);
  }
}
```

## State / Controller / Binding

Same as before: immutable state + status; controller `try/catch` → `_errorState`; Binding Service → UseCase → Controller with `fenix: true`.
