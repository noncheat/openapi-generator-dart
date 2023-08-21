import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// Config base class
/// Your annotated class must extend this config class
@Deprecated(
    'You do not need to extend this anymore (See example). This class would be removed in the next major release.')
abstract class OpenapiGeneratorConfig {}

class Openapi {
  /// Additional properties to pass to the compiler (CSV)
  ///
  /// --additional-properties
  final AdditionalProperties? additionalProperties;

  // /// Allows you to customize how inline schemas are handled or named
  // ///
  // /// --inline-schema-options
  // final InlineSchemaOptions? inlineSchemaOptions;

  /// The package of the api. defaults to lib.api
  ///
  /// --api-package
  final String? apiPackage;

  /// relative path or url to spec file
  ///
  /// -i
  final String inputSpecFile;

  /// Provides the access information to the input spec file.
  ///
  /// For use with useNextGen.
  ///
  /// The next generation of the OAS spec file information. Allows for local and
  /// remote spec files.
  ///
  /// This version of the spec file configuration allows for custom authorization
  /// to be applied to the fetch request when the spec file is in a remote
  /// location. There is also special handling for when the spec file lives within
  /// AWS.
  final InputSpec? inputSpec;

  /// folder containing the template files
  ///
  /// You can read more about templating here
  /// https://github.com/OpenAPITools/openapi-generator/blob/master/docs/templating.md
  /// -t
  final String? templateDirectory;

  /// Generator to use (dart|dart2-api|dart-jaguar|dart-dio)
  ///
  /// -g, --generator-name
  final Generator generatorName;

  ///  Where to write the generated files (current dir by default)
  ///
  ///  -o, --output
  final String? outputDirectory;

  ///  Specifies if the existing files should be overwritten during the generation
  ///
  ///  -s, --skip-overwrite
  final bool? overwriteExistingFiles;

  /// Skips the default behavior of validating an input specification.
  ///
  /// --skip-validate-spec
  final bool? skipSpecValidation;

  /// Add reserved words mappings as reservedWord=replacement format.
  /// It is supported by the dart2-api and dart-dio generator.
  ///
  /// --reserved-words-mappings
  final Map<String, String>? reservedWordsMappings;

  /// Tells openapi-generator to always run during the build process
  /// if set to false (the default), openapi-generator will skip processing if the [outputDirectory] already exists
  final bool? alwaysRun;

  /// if set to true, flutter pub get will be run on the [outputDirectory] after the code has been generated.
  /// Defaults to true for backwards compatibility
  final bool? fetchDependencies;

  ///if set to true, source gen will be run on the output of openapi-generator
  ///Defaults to true
  final bool? runSourceGenOnOutput;

  ///  sets mappings between OpenAPI spec types and generated code types in
  ///  the format of OpenAPIType=generatedType,OpenAPIType=generatedType.
  ///  For example: array=List,map=Map,string=String. You can also have
  ///  multiple occurrences of this option. To map a specified format, use
  ///  type+format, e.g. string+password=EncryptedString will map `type:
  ///  string, format: password` to `EncryptedString`.
  ///
  ///   --type-mappings
  final Map<String, String>? typeMappings;

  /// specifies mappings between a given class and the import that should
  /// be used for that class in the format of type=import,type=import. You
  /// can also have multiple occurrences of this option.
  ///
  /// --import-mappings
  ///
  /// e.g {'OffsetDate': 'package:time_machine/time_machine.dart'}
  final Map<String, String>? importMappings;

  /// Inline schemas are created as separate schemas automatically and the
  /// auto-generated schema name may not look good to everyone. One can customize
  /// the name using the title field or the inlineSchemaNameMapping option.
  ///
  /// --inline-schema-name-mappings
  ///
  /// e.g {'inline_object_2': 'SomethingMapped'}
  final Map<String, String>? inlineSchemaNameMappings;

  /// Use the next generation of the generator.
  ///
  /// This annotation informs the generator to use the new generator pathway.
  /// Enabling this option allows for incremental changes to the [inputSpecFile]
  /// to be generated even though the annotation was unchanged.
  ///
  /// Due to some limitations with build_runner and it only running when the
  /// asset graph has changed, a generated line get injected at the beginning of
  /// the file at the end of each run.
  ///
  /// This will become the default behaviour in the next Major version (v5).
  ///
  /// Default: false
  final bool useNextGen;

  /// The path where to store the cached copy of the specification.
  ///
  /// For use with [useNextGen].
  final String? cachePath;

  /// Use a custom pubspec when running the generator.
  final String? projectPubspecPath;

  /// Include in depth logging output from run commands.
  final bool debugLogging;

  const Openapi({
    this.additionalProperties,
    @deprecated this.overwriteExistingFiles,
    this.skipSpecValidation = false,
    required this.inputSpecFile,
    this.inputSpec,
    this.templateDirectory,
    required this.generatorName,
    this.outputDirectory,
    this.typeMappings,
    this.importMappings,
    this.reservedWordsMappings,
    this.inlineSchemaNameMappings,
    // this.inlineSchemaOptions,
    this.apiPackage,
    this.fetchDependencies = true,
    this.runSourceGenOnOutput = true,
    @deprecated this.alwaysRun = false,
    this.cachePath,
    this.useNextGen = false,
    this.projectPubspecPath,
    this.debugLogging = false,
  });
}

/// Provides the input spec file to be used.
///
/// Provides the location of the input spec file to be used by the generator.
/// Includes the option to use the default json or yaml paths.
class InputSpec {
  final String path;
  final bool defaultYaml;

  const InputSpec({String? path, this.defaultYaml = true})
      : path = path ?? 'openapi.${defaultYaml ? 'yaml' : 'json'}';

  const InputSpec.empty() : this();

  const InputSpec.emptyJson() : this(defaultYaml: false);

  Map<String, dynamic> toJsonMap() =>
      {'path': path, 'defaultYaml': defaultYaml};

  InputSpec.fromMap(Map<String, dynamic> map)
      : this(
          path: map['path'],
          defaultYaml: map['defaultYaml'] == 'true' ? true : false,
        );
}

/// Provides the location for the remote specification.
///
/// Provides basic support for fetching remote specification files hidden behind
/// an authenticated endpoint.
///
/// By default when no [url] is provided a default [Uri.http] to
/// localhost:8080/PWD is used.
///
/// This contains authentication information for fetching the OAS spec ONLY. This
/// does not apply security to the entry points defined in the OAS spec.
class RemoteSpec extends InputSpec {
  final String? authHeaderContent;

  const RemoteSpec({
    required super.path,
    this.authHeaderContent,
  });

  const RemoteSpec.empty() : this(path: 'http://localhost:8080/');

  Uri get url => Uri.parse(path);

  Map<String, String> toHeaderMap() {
    return {
      if (authHeaderContent != null)
        'Authorization': 'Bearer ${authHeaderContent}',
    };
  }

  Map<String, dynamic> toJsonMap() {
    return {
      if (authHeaderContent != null) 'authHeaderContent': authHeaderContent!,
      ...super.toJsonMap(),
    };
  }

  RemoteSpec.fromMap(Map<String, dynamic> map)
      : authHeaderContent = map['authHeaderContent'],
        super.fromMap(map);
}

/// Indicates whether or not the spec file live within AWS.
///
/// Since AWS handles the authentication header differently, we need to inform
/// the builder to include the alternate auth header.
///
/// This currently only support AWS S3.
///
/// This contains authentication information for fetching the OAS spec ONLY. This
/// does not apply security to the entry points defined in the OAS spec.
class AwsRemoteSpec extends RemoteSpec {
  /// The accessKeyId use to interact with AWS.
  ///
  /// When this is null authentication will fail.
  final String? _accessKeyId;

  @visibleForTesting
  String? get accessKeyId => _accessKeyId;

  /// The secretAccessKey for the user.
  ///
  /// When this is null the requests wil not be authenticated.
  final String? _secretAccessKey;

  @visibleForTesting
  String? get secretAccessKey => _secretAccessKey;

  /// The region where the AWS resource resides.
  final String region;

  /// The S3 bucket name.
  final String bucket;

  /// The current timestamp.
  ///
  /// This shouldn't be manually provided.
  final DateTime? now;

  /// Creates a reference to an OAS spec hosted within AWS S3.
  ///
  /// [accessKeyId] User AWS accessKeyId
  /// [secretAccessKeyId] User AWS secretAccessKeyId
  /// [region] The region to target within AWS.
  /// [bucket] The S3 bucket to target.
  /// [path] The path of the OAS spec from the root of the [bucket] without the
  ///   leading /.
  const AwsRemoteSpec({
    String? accessKeyId,
    String? secretAccessKey,
    required this.region,
    required this.bucket,
    required super.path,
    this.now,
  })  : _secretAccessKey = secretAccessKey,
        _accessKeyId = accessKeyId;

  /// The url of the OAS spec within S3.
  @override
  Uri get url => Uri.https('$bucket.s3.$region.amazonaws.com', '/$path');

  /// The [Authentication] header content.
  ///
  /// This builds the Authorization header content format used by AWS.
  ///
  /// Multiple calls will result in the same content unless [toHeaderMap] has been
  /// called in between.
  String get authHeaderContent {
    if (_secretAccessKey == null || _accessKeyId == null) {
      return '';
    }
    // https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html#RESTAuthenticationExamples
    String toSign = [
      'GET',
      '',
      '',
      now,
      '/$bucket/$path',
    ].join('\n');

    final utf8AKey = utf8.encode(_secretAccessKey!);
    final utf8ToSign = utf8.encode(toSign);

    final signature =
        base64Encode(Hmac(sha1, utf8AKey).convert(utf8ToSign).bytes);
    return 'AWS $_accessKeyId:$signature';
  }

  /// Load the user credentials from the environment.
  AwsRemoteSpec loadCredentials() => AwsRemoteSpec(
        region: region,
        bucket: bucket,
        path: path,
        accessKeyId: Platform.environment['AWS_ACCESS_KEY_ID'],
        secretAccessKey: Platform.environment['AWS_SECRET_ACCESS_KEY'],
        now: DateTime.now(),
      );

  /// Builds the headers map for the authenticated request.
  ///
  /// This will return an empty map when when the [_accessKeyId] or [_secretAccessKey]
  /// are empty after attempting to fetch them from the environment.
  Map<String, String> toHeaderMap() {
    AwsRemoteSpec specAuth = this;
    if (_accessKeyId == null || _secretAccessKey == null || now == null) {
      specAuth = loadCredentials();
      if (specAuth.accessKeyId == null ||
          specAuth.secretAccessKey == null ||
          now == null) {
        // TODO: This should probably throw or assert
        return {};
      }
    }

    return {
      'Authorization': authHeaderContent,
      'x-amz-date': now!.toIso8601String(),
    };
  }

  Map<String, String> toJsonMap() {
    return {
      if (_accessKeyId != null) 'accessKeyId': _accessKeyId!,
      if (_secretAccessKey != null) 'secretAccessKey': _secretAccessKey!,
      'path': path,
      'bucket': bucket,
      'region': region,
      ...super.toJsonMap(),
    };
  }

  AwsRemoteSpec.fromMap(Map<String, dynamic> map)
      : bucket = map['bucket'],
        region = map['region'],
        _accessKeyId = map['accessKeyId'],
        _secretAccessKey = map['secretAccessKey'],
        now = DateTime.now(),
        super.fromMap(map);
}

/// A localstack remote spec for testing AWS like requests.
@visibleForTesting
class LocalStackRemoteSpec extends AwsRemoteSpec {
  final int localStackPort;

  const LocalStackRemoteSpec({
    super.path,
    this.localStackPort = 4566,
  }) : super(
          region: 'us-east-1',
          accessKeyId: 'test',
          secretAccessKey: 'test',
          bucket: 'bucket',
        );

  Uri get url => Uri.http(
      '$bucket.s3.$region.localhost.localstack.cloud:$localStackPort',
      '/$path');

  LocalStackRemoteSpec.fromMap(Map<String, dynamic> map)
      : localStackPort = map['localStackPort'] ?? 4566,
        super.fromMap(map);
}

class AdditionalProperties {
  ///  toggles whether unicode identifiers are allowed in names or not, default is false
  final bool? allowUnicodeIdentifiers;

  /// Whether to ensure parameter names are unique in an operation (rename parameters that are not).
  final bool? ensureUniqueParams;

  /// Add form or body parameters to the beginning of the parameter list.
  final bool? prependFormOrBodyParameters;

  ///	Author name in generated pubspec
  final String? pubAuthor;

  /// 	Email address of the author in generated pubspec
  final String? pubAuthorEmail;

  ///	Description in generated pubspec
  final String? pubDescription;

  ///	Homepage in generated pubspec
  final String? pubHomepage;

  ///	Name in generated pubspec
  final String? pubName;

  /// Version in generated pubspec
  final String? pubVersion;

  /// Sort model properties to place required parameters before optional parameters.
  final bool? sortModelPropertiesByRequiredFlag;

  /// Sort method arguments to place required parameters before optional parameters.
  final bool? sortParamsByRequiredFlag;

  /// Source folder for generated code
  final String? sourceFolder;

  /// Allow the 'x-enum-values' extension for enums
  final bool? useEnumExtension;

  /// Flutter wrapper to use (none|flutterw|fvm)
  final Wrapper wrapper;

  /// Set to true for generators with better support for discriminators.
  /// (Python, Java, Go, PowerShell, C#have this enabled by default).
  ///
  /// true
  /// The mapping in the discriminator includes descendent schemas that allOf
  /// inherit from self and the discriminator mapping schemas in the OAS document.
  ///
  /// false
  /// The mapping in the discriminator includes any descendent schemas that allOf
  /// inherit from self, any oneOf schemas, any anyOf schemas, any x-discriminator-values,
  /// and the discriminator mapping schemas in the OAS document AND Codegen validates
  /// that oneOf and anyOf schemas contain the required discriminator and throws
  /// an error if the discriminator is missing.
  final bool legacyDiscriminatorBehavior;

  const AdditionalProperties({
    this.allowUnicodeIdentifiers = false,
    this.ensureUniqueParams = true,
    this.useEnumExtension = false,
    this.prependFormOrBodyParameters = false,
    this.pubAuthor,
    this.pubAuthorEmail,
    this.pubDescription,
    this.pubHomepage,
    this.legacyDiscriminatorBehavior = true,
    this.pubName,
    this.pubVersion,
    this.sortModelPropertiesByRequiredFlag = true,
    this.sortParamsByRequiredFlag = true,
    this.sourceFolder,
    this.wrapper = Wrapper.none,
  });

  /// Produces an [AdditionalProperties] object from the [ConstantReader] [map].
  AdditionalProperties.fromMap(Map<String, dynamic> map)
      : this(
          allowUnicodeIdentifiers: map['allowUnicodeIdentifiers'] ?? false,
          ensureUniqueParams: map['ensureUniqueParams'] ?? true,
          useEnumExtension: map['useEnumExtension'] ?? true,
          prependFormOrBodyParameters:
              map['prependFormOrBodyParameters'] ?? false,
          pubAuthor: map['pubAuthor'],
          pubAuthorEmail: map['pubAuthorEmail'],
          pubDescription: map['pubDescription'],
          pubHomepage: map['pubHomepage'],
          pubName: map['pubName'],
          pubVersion: map['pubVersion'],
          legacyDiscriminatorBehavior:
              map['legacyDiscriminatorBehavior'] ?? true,
          sortModelPropertiesByRequiredFlag:
              map['sortModelPropertiesByRequiredFlag'] ?? true,
          sortParamsByRequiredFlag: map['sortParamsByRequiredFlag'] ?? true,
          sourceFolder: map['sourceFolder'],
          wrapper: EnumTransformer.wrapper(map['wrapper']),
        );

  Map<String, dynamic> toMap() => {
        'allowUnicodeIdentifiers': allowUnicodeIdentifiers,
        'ensureUniqueParams': ensureUniqueParams,
        'useEnumExtension': useEnumExtension,
        'prependFormOrBodyParameters': prependFormOrBodyParameters,
        if (pubAuthor != null) 'pubAuthor': pubAuthor,
        if (pubAuthorEmail != null) 'pubAuthorEmail': pubAuthorEmail,
        if (pubDescription != null) 'pubDescription': pubDescription,
        if (pubHomepage != null) 'pubHomepage': pubHomepage,
        if (pubName != null) 'pubName': pubName,
        if (pubVersion != null) 'pubVersion': pubVersion,
        'legacyDiscriminatorBehavior': legacyDiscriminatorBehavior,
        'sortModelPropertiesByRequiredFlag': sortModelPropertiesByRequiredFlag,
        'sortParamsByRequiredFlag': sortParamsByRequiredFlag,
        if (sourceFolder != null) 'sourceFolder': sourceFolder,
        'wrapper': EnumTransformer.wrapperName(wrapper)
      };
}

/// Allows you to customize how inline schemas are handled or named
class InlineSchemaOptions {
  ///  sets the array item suffix
  final String? arrayItemSuffix;

  /// set the map item suffix
  final String? mapItemSuffix;

  /// special value to skip reusing inline schemas during refactoring
  final bool skipSchemaReuse;

  ///	will restore the 6.x (or below) behaviour to refactor allOf inline schemas
  ///into $ref. (v7.0.0 will skip the refactoring of these allOf inline schemas by default)
  final bool refactorAllofInlineSchemas;

  /// Email address of the author in generated pubspec
  final bool resolveInlineEnums;

  const InlineSchemaOptions(
      {this.arrayItemSuffix,
      this.mapItemSuffix,
      this.skipSchemaReuse = true,
      this.refactorAllofInlineSchemas = true,
      this.resolveInlineEnums = true});

  /// Produces an [InlineSchemaOptions] that is easily consumable from the [ConstantReader].
  InlineSchemaOptions.fromMap(Map<String, dynamic> map)
      : this(
          arrayItemSuffix: map['arrayItemSuffix'],
          mapItemSuffix: map['mapItemSuffix'],
          skipSchemaReuse: map['skipSchemaReuse'] ?? true,
          refactorAllofInlineSchemas: map['refactorAllofInlineSchemas'] ?? true,
          resolveInlineEnums: map['resolveInlineEnums'] ?? true,
        );

  /// A convenience function that simplifies the output to the compiler.
  Map<String, dynamic> toMap() => {
        if (arrayItemSuffix != null) 'arrayItemSuffix': arrayItemSuffix!,
        if (mapItemSuffix != null) 'mapItemSuffix': mapItemSuffix!,
        'skipSchemaReuse': skipSchemaReuse,
        'refactorAllofInlineSchemas': refactorAllofInlineSchemas,
        'resolveInlineEnums': resolveInlineEnums,
      };
}

class DioProperties extends AdditionalProperties {
  /// Choose serialization format JSON or PROTO is supported
  final DioDateLibrary? dateLibrary;
  final DioSerializationLibrary? serializationLibrary;

  /// Is the null fields should be in the JSON payload
  final bool? nullableFields;

  const DioProperties(
      {this.dateLibrary,
      this.nullableFields,
      this.serializationLibrary,
      bool allowUnicodeIdentifiers = false,
      bool ensureUniqueParams = true,
      bool prependFormOrBodyParameters = false,
      String? pubAuthor,
      String? pubAuthorEmail,
      String? pubDescription,
      String? pubHomepage,
      String? pubName,
      String? pubVersion,
      bool sortModelPropertiesByRequiredFlag = true,
      bool sortParamsByRequiredFlag = true,
      bool useEnumExtension = true,
      String? sourceFolder,
      Wrapper wrapper = Wrapper.none})
      : super(
            allowUnicodeIdentifiers: allowUnicodeIdentifiers,
            ensureUniqueParams: ensureUniqueParams,
            prependFormOrBodyParameters: prependFormOrBodyParameters,
            pubAuthor: pubAuthor,
            pubAuthorEmail: pubAuthorEmail,
            pubDescription: pubDescription,
            pubHomepage: pubHomepage,
            pubName: pubName,
            pubVersion: pubVersion,
            sortModelPropertiesByRequiredFlag:
                sortModelPropertiesByRequiredFlag,
            sortParamsByRequiredFlag: sortParamsByRequiredFlag,
            sourceFolder: sourceFolder,
            useEnumExtension: useEnumExtension,
            wrapper: wrapper);

  DioProperties.fromMap(Map<String, dynamic> map)
      : dateLibrary = EnumTransformer.dioDateLibrary(map['dateLibrary']),
        nullableFields = map['nullableFields'] != null
            ? map['nullableFields'] == 'true'
            : null,
        serializationLibrary = EnumTransformer.dioSerializationLibrary(
            map['serializationLibrary']),
        super.fromMap(map);

  Map<String, dynamic> toMap() => Map.from(super.toMap())
    ..addAll({
      if (dateLibrary != null)
        'dateLibrary': EnumTransformer.dioDateLibraryName(dateLibrary!),
      if (nullableFields != null) 'nullableFields': nullableFields,
      if (serializationLibrary != null)
        'serializationLibrary':
            EnumTransformer.dioSerializationLibraryName(serializationLibrary!),
    });
}

class DioAltProperties extends AdditionalProperties {
  /// Changes the minimum version of Dart to 2.12 and generate null safe code
  final bool? nullSafe;

  /// nullSafe-array-default
  /// Makes even arrays that are not listed as being required in your OpenAPI "required"
  /// but making them always generate a default value of []
  final bool? nullSafeArrayDefault;

  /// This will turn off AnyOf support. This would be a bit weird, but you can do it if you want.
  final bool? listAnyOf;

  /// Anything in this will be split on a command added to the dependencies section of your generated code.
  /// pubspec-dependencies
  final String? pubspecDependencies;

  /// pubspec-dev-dependencies
  /// Anything here will be added to the dev dependencies of your generated code.
  final String? pubspecDevDependencies;

  const DioAltProperties(
      {this.nullSafe,
      this.nullSafeArrayDefault,
      this.pubspecDependencies,
      this.pubspecDevDependencies,
      this.listAnyOf,
      bool allowUnicodeIdentifiers = false,
      bool ensureUniqueParams = true,
      bool prependFormOrBodyParameters = false,
      String? pubAuthor,
      String? pubAuthorEmail,
      String? pubDescription,
      String? pubHomepage,
      String? pubName,
      String? pubVersion,
      bool sortModelPropertiesByRequiredFlag = true,
      bool sortParamsByRequiredFlag = true,
      bool useEnumExtension = true,
      String? sourceFolder,
      Wrapper wrapper = Wrapper.none})
      : super(
            allowUnicodeIdentifiers: allowUnicodeIdentifiers,
            ensureUniqueParams: ensureUniqueParams,
            prependFormOrBodyParameters: prependFormOrBodyParameters,
            pubAuthor: pubAuthor,
            pubAuthorEmail: pubAuthorEmail,
            pubDescription: pubDescription,
            pubHomepage: pubHomepage,
            pubName: pubName,
            pubVersion: pubVersion,
            sortModelPropertiesByRequiredFlag:
                sortModelPropertiesByRequiredFlag,
            sortParamsByRequiredFlag: sortParamsByRequiredFlag,
            sourceFolder: sourceFolder,
            useEnumExtension: useEnumExtension,
            wrapper: wrapper);

  DioAltProperties.fromMap(Map<String, dynamic> map)
      : nullSafe = map['nullSafe'] != null ? map['nullSafe'] == 'true' : null,
        nullSafeArrayDefault = map['nullSafeArrayDefault'] != null
            ? map['nullSafeArrayDefault'] == 'true'
            : null,
        listAnyOf =
            map['listAnyOf'] != null ? map['listAnyOf'] == 'true' : null,
        pubspecDependencies = map['pubspecDependencies'],
        pubspecDevDependencies = map['pubspecDevDependencies'],
        super.fromMap(map);

  Map<String, dynamic> toMap() => Map.from(super.toMap())
    ..addAll({
      if (nullSafe != null) 'nullSafe': nullSafe,
      if (nullSafeArrayDefault != null)
        'nullSafeArrayDefault': nullSafeArrayDefault,
      if (listAnyOf != null) 'listAnyOf': listAnyOf,
      if (pubspecDependencies != null)
        'pubspecDependencies': pubspecDependencies,
      if (pubspecDevDependencies != null)
        'pubspecDevDependencies': pubspecDevDependencies,
    });
}

enum DioDateLibrary {
  /// Dart core library (DateTime)
  core,

  /// Time Machine is date and time library for Flutter, Web, and Server with
  /// support for timezones, calendars, cultures, formatting and parsing.
  timemachine
}

enum DioSerializationLibrary { built_value, json_serializable }

enum SerializationFormat { JSON, PROTO }

/// The name of the generator to use
enum Generator {
  /// This generator uses the default http package that comes with dart
  /// corresponds to dart
  dart,

  /// This generator uses the dio package. Source gen is required after generating code with this generator
  /// corresponds to dart-dio
  ///
  /// A powerful Http client for Dart, which supports Interceptors, Global configuration,
  /// FormData, Request Cancellation, File downloading, Timeout etc
  /// https://pub.flutter-io.cn/packages/dio
  dio,

  /// This uses the generator provided by bluetrainsoftware which internally uses the dio package
  ///
  /// You can read more about it here https://github.com/dart-ogurets/dart-openapi-maven
  dioAlt,
}

// TODO: Upon release of NextGen as default migrate to sdk 2.17 for enhanced enums
//  remove this work around.
/// Transforms the enums used with the [Openapi] annotation.
class EnumTransformer {
  static DioDateLibrary? dioDateLibrary(String? name) {
    switch (name) {
      case 'timemachine':
        return DioDateLibrary.timemachine;
      case 'core':
        return DioDateLibrary.core;
    }
    return null;
  }

  static String dioDateLibraryName(DioDateLibrary lib) {
    switch (lib) {
      case DioDateLibrary.timemachine:
        return 'timemachine';
      default:
        return 'core';
    }
  }

  static DioSerializationLibrary? dioSerializationLibrary(String? name) {
    switch (name) {
      case 'json_serializable':
        return DioSerializationLibrary.json_serializable;
      case 'built_value':
        return DioSerializationLibrary.built_value;
    }
    return null;
  }

  static String dioSerializationLibraryName(DioSerializationLibrary lib) {
    switch (lib) {
      case DioSerializationLibrary.json_serializable:
        return 'json_serializable';
      default:
        return 'built_value';
    }
  }

  /// Converts the given [name] to the matching [Generator] name.
  ///
  /// Defaults to [Generator.dart];
  static Generator generator(String? name) {
    switch (name) {
      case 'dio':
        return Generator.dio;
      case 'dioAlt':
        return Generator.dioAlt;
      default:
        return Generator.dart;
    }
  }

  static String generatorName(Generator generator) {
    switch (generator) {
      case Generator.dio:
        return 'dart-dio';
      case Generator.dioAlt:
        return 'dart2-api';
      default:
        return 'dart';
    }
  }

  /// Converts the given [name] to the matching [Wrapper] name.
  ///
  /// Defaults to [Wrapper.none];
  static Wrapper wrapper(String? name) {
    switch (name) {
      case 'fvm':
        return Wrapper.fvm;
      case 'flutterw':
        return Wrapper.flutterw;
      default:
        return Wrapper.none;
    }
  }

  static String wrapperName(Wrapper wrapper) {
    switch (wrapper) {
      case Wrapper.flutterw:
        return 'flutterw';
      case Wrapper.fvm:
        return 'fvm';
      default:
        return 'none';
    }
  }
}

enum Wrapper { fvm, flutterw, none }
