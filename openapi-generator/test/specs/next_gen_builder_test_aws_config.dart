library test_lib;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
    inputSpec: RemoteSpec(
      path:
          'http://bucket.s3.us-east-1.localhost.localstack.cloud:4566/openapi.yaml',
      headerDelegate: AWSRemoteSpecHeaderDelegate(
        bucket: 'bucket',
        accessKeyId: 'test',
        secretAccessKey: 'test',
      ),
    ),
    generatorName: Generator.dio,
    cachePath: './test/specs/output-nextgen/expected-args/cache.json',
    outputDirectory: './test/specs/output-nextgen/expected-args')
class TestClassConfig {}
