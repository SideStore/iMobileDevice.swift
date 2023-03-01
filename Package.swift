// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import os.log
import PackageDescription

let env: [String: Bool] = [
    "USE_CARGO": false,
    "USE_CXX_INTEROP": false,
    "USE_CXX_MODULES": false,
    "INHIBIT_UPSTREAM_WARNINGS": true,
    "STATIC_LIBRARY": false,
]

let USE_CARGO = envBool("USE_CARGO")
let USE_CXX_INTEROP = envBool("USE_CXX_INTEROP")
let USE_CXX_MODULES = envBool("USE_CXX_MODULES")
let INHIBIT_UPSTREAM_WARNINGS = envBool("INHIBIT_UPSTREAM_WARNINGS")
let STATIC_LIBRARY = envBool("STATIC_LIBRARY")

let unsafe_flags: [String] = INHIBIT_UPSTREAM_WARNINGS ? ["-w"] : []
let unsafe_flags_cxx: [String] = INHIBIT_UPSTREAM_WARNINGS ? ["-w", "-Wno-module-import-in-extern-c"] : ["-Wno-module-import-in-extern-c"]

let package = Package(
    name: "iMobileDevice",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macCatalyst(.v14),
        .macOS(.v11),
    ],

    products: [
		// MARK: - iMobileDevice
		.library(
			name: "iMobileDevice",
			targets: ["iMobileDevice"]),

		.library(
			name: "iMobileDevice-Static",
			type: .static,
			targets: ["iMobileDevice"]),

		.library(
			name: "iMobileDevice-Dynamic",
			type: .dynamic,
			targets: ["iMobileDevice"]),

		// MARK: - libimobiledevice

		.library(
			name: "libimobiledevice",
			targets: ["libimobiledevice", "libplist", "libusbmuxd", "libimobiledevice-glue"]),

		.library(
			name: "libimobiledevice-Static",
			type: .static,
			targets: ["libimobiledevice", "libplist", "libusbmuxd", "libimobiledevice-glue"]),

		.library(
			name: "libimobiledevice-Dynamic",
			type: .dynamic,
			targets: ["libimobiledevice", "libplist", "libusbmuxd", "libimobiledevice-glue"]),


		// MARK: - libfragmentzip

		.library(
			name: "libfragmentzip",
			targets: ["libfragmentzip"]),

		.library(
			name: "libfragmentzip-static",
			type: .static,
			targets: ["libfragmentzip"]),

		.library(
			name: "libfragmentzip-dynamic",
			type: .dynamic,
			targets: ["libfragmentzip"]),
    ],

	dependencies: [
		.package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .upToNextMinor(from: "1.1.1700")),
	],

	targets: [
		.target(
			name: "iMobileDevice",
			dependencies: [
				"libimobiledevice", "libplist", "libusbmuxd", "libimobiledevice-glue"
			],
			cSettings: [
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/common"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libplist/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libusbmuxd/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags)
			],
			cxxSettings: [
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/common"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libplist/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libusbmuxd/include"),				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags_cxx)
			]
		),

        // MARK: - libfragmentzip
		.executableTarget(
			name: "libfragmentzip-cli",
			dependencies: [
				"libfragmentzip",
				"libcurl",
			],
			path: "Sources/libfragmentzip",
			sources: [
				"libfragmentzip-source/libfragmentzip/main.c",
			],
			publicHeadersPath: "include",
			cSettings: [
				.headerSearchPath("include"),
				.headerSearchPath("libfragmentzip-source/include"),
				.headerSearchPath("libfragmentzip-source/include/libfragmentzip"),
				.headerSearchPath("libfragmentzip-source/dependencies/libgeneral/include"),
			],
			cxxSettings: [
				.headerSearchPath("include"),
				.headerSearchPath("libfragmentzip-source/include"),
				.headerSearchPath("libfragmentzip-source/include/libfragmentzip"),
				.headerSearchPath("libfragmentzip-source/dependencies/libgeneral/include")
			],
			linkerSettings: [
				.linkedLibrary("z"),
			]
		),

		.systemLibrary(
			name: "libcurl",
			pkgConfig: "curl",
			providers: [
				.brew(["curl"]),
				.apt(["libcurl4-openssl-dev"])
			]
		),

        .target(
            name: "libfragmentzip",
            dependencies: [
				"libcurl",
			],
			exclude: [
				"libfragmentzip-source/dependencies",
				"libfragmentzip-source/fragmentzip",
				"libfragmentzip-source/include"
			],
            sources: [
                "libfragmentzip-source/libfragmentzip/libfragmentzip.c",
            ],
			publicHeadersPath: "include",
            cSettings: [
				.headerSearchPath("include"),
                .headerSearchPath("libfragmentzip-source/include"),
				.headerSearchPath("libfragmentzip-source/dependencies/libgeneral/include"),
			],
			cxxSettings: [
				.headerSearchPath("include"),
				.headerSearchPath("libfragmentzip-source/include"),
				.headerSearchPath("libfragmentzip-source/dependencies/libgeneral/include")
			],
			linkerSettings: [
				.linkedLibrary("z"),
				.linkedLibrary("curl", .when(platforms: [.macOS])),
			]
        ),

        .testTarget(
            name: "libfragmentzipTests",
            dependencies: [
				"libfragmentzip",
				"libcurl"]
        ),

        // MARK: - libmobiledevice

        .target(
            name: "libimobiledevice",
            dependencies: [
                "libimobiledevice-glue",
                "libplist",
                "libusbmuxd",
				"OpenSSL"
            ],
            path: "Sources/libimobiledevice/libimobiledevice/",
            publicHeadersPath: "include/",
			cSettings: [
				.headerSearchPath("include/"),
				.headerSearchPath("../dependencies/libimobiledevice"),
				.headerSearchPath("../dependencies/libimobiledevice/common"),
				.headerSearchPath("../dependencies/libimobiledevice/include"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../dependencies/libplist/include"),
				.headerSearchPath("../dependencies/libusbmuxd/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags)
			],
			cxxSettings: [
				.headerSearchPath("include/"),
				.headerSearchPath("../dependencies/libimobiledevice"),
				.headerSearchPath("../dependencies/libimobiledevice/common"),
				.headerSearchPath("../dependencies/libimobiledevice/include"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../dependencies/libplist/include"),
				.headerSearchPath("../dependencies/libusbmuxd/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags_cxx)
			]
        ),

		.testTarget(
			name: "libimobiledeviceTests",
			dependencies: [
				"libimobiledevice"
			],
			cSettings: [
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/common"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libplist/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libusbmuxd/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags)
			],
			cxxSettings: [
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/common"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libplist/include"),
				.headerSearchPath("../libimobiledevice/dependencies/libusbmuxd/include"),				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags_cxx)
			]
		),

		// MARK: libmobiledevice-glue
        .target(
            name: "libimobiledevice-glue",
            dependencies: [
				"libplist"
            ],
            path: "Sources/libimobiledevice/libimobiledevice-glue/",
            exclude: [
				"src/libimobiledevice-glue-1.0.pc.in",
				"src/common.h"
			],
            publicHeadersPath: "include",
			cSettings: [
				.headerSearchPath("include/"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../dependencies/libplist/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags)
			],
			cxxSettings: [
				.headerSearchPath("include/"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include"),
				.headerSearchPath("../dependencies/libplist/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags_cxx)
			]
        ),

        // MARK: libplist

        .target(
            name: "libplist",
            path: "Sources/libimobiledevice/libplist/",
            sources: [
                "src/base64.c",
                "src/bplist.c",
                "src/bytearray.c",
                "src/hashtable.c",
				"src/jplist.c",
				"src/jsmn.c",
				"src/oplist.c",
                "src/plist.c",
                "src/ptrarray.c",
                "src/time64.c",
                "src/xplist.c",
                "src/Array.cpp",
                "src/Boolean.cpp",
                "src/Data.cpp",
                "src/Date.cpp",
                "src/Dictionary.cpp",
                "src/Integer.cpp",
                "src/Key.cpp",
                "src/Node.cpp",
                "src/Real.cpp",
                "src/String.cpp",
                "src/Structure.cpp",
                "src/Uid.cpp",
				"libcnary/node.c",
				"libcnary/node_list.c",
            ],
            publicHeadersPath: "include",
            cSettings: [
				.headerSearchPath("include/"),
                .headerSearchPath("../dependencies/libplist/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags)
            ],
            cxxSettings: [
				.headerSearchPath("include/"),
				.headerSearchPath("../dependencies/libplist/include"),
				.headerSearchPath("../dependencies/libplist/libcnary/include"),
				.define("HAVE_OPENSSL"),
				.define("HAVE_STPNCPY"),
				.define("HAVE_STPCPY"),
				.define("HAVE_VASPRINTF"),
				.define("HAVE_ASPRINTF"),
				.define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
				.define("HAVE_GETIFADDRS"),
				.define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags_cxx)
            ]
        ),

        // MARK: libusbmuxd

        .target(
            name: "libusbmuxd",
            dependencies: [
				"libplist",
				"libimobiledevice-glue"
            ],
            path: "Sources/libimobiledevice/libusbmuxd/",
            sources: [
                "src/libusbmuxd.c",
            ],
            publicHeadersPath: "include",
            cSettings: [
				.headerSearchPath("../dependencies/libplist/include"),
				.headerSearchPath("../dependencies/libplist/libcnary/include"),
				.headerSearchPath("../dependencies/libusbmuxd/include"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include/"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include/libimobiledevice-glue/"),
                .define("HAVE_OPENSSL"),
                .define("HAVE_STPNCPY"),
                .define("HAVE_STPCPY"),
                .define("HAVE_VASPRINTF"),
                .define("HAVE_ASPRINTF"),
                .define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
                .define("HAVE_GETIFADDRS"),
                .define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags)
            ],
            cxxSettings: [
				.headerSearchPath("../dependencies/libplist/include"),
				.headerSearchPath("../dependencies/libplist/libcnary/include"),
				.headerSearchPath("../dependencies/libusbmuxd/include"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include/"),
				.headerSearchPath("../dependencies/libimobiledevice-glue/include/libimobiledevice-glue/"),
                .define("HAVE_OPENSSL"),
                .define("HAVE_STPNCPY"),
                .define("HAVE_STPCPY"),
                .define("HAVE_VASPRINTF"),
                .define("HAVE_ASPRINTF"),
                .define("PACKAGE_STRING", to: "\"AltServer 1.0\""),
                .define("HAVE_GETIFADDRS"),
                .define("HAVE_STRNDUP"),
				.unsafeFlags(unsafe_flags_cxx)
            ]
        )
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)

// MARK: - Helpers

func envBool(_ key: String) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[key] else { return env[key, default: true] }
    let trueValues = ["1", "on", "true", "yes"]
    return trueValues.contains(value.lowercased())
}

func envString(_ key: String) -> String? {
	guard let value = ProcessInfo.processInfo.environment[key] else { return env[key, default: false] ? "true" : "false" }
    return value
}
