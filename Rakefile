require 'rake/clean'
require_relative 'fruit/build_helpers'
require_relative 'fruit/fruit_processor'

COMPILER = "gfortran"
FFLAGS = "-Wall -Wextra -Werror -pedantic"
DEVEL_FLAGS = "-g"
DEVEL_DIR = File.join("build", "devel")
RELEASE_FLAGS = "-O2"
RELEASE_DIR = File.join("build", "release")

UNIT_TEST_BUILD_DIR = File.join("unit_test", "build")
UNIT_TEST_BASKET_SOURCE_FILE = File.join(UNIT_TEST_BUILD_DIR, "fruit_basket.f90")
UNIT_TEST_DRIVER_SOURCE_FILE = File.join(UNIT_TEST_BUILD_DIR, "fruit_driver.f90")
UNIT_TEST_RESULTS_FILE = File.join(UNIT_TEST_BUILD_DIR, "results.xml")

INTEGRATION_TEST_BUILD_DIR = File.join("integration_test", "build")
INTEGRATION_TEST_BASKET_SOURCE_FILE = File.join(INTEGRATION_TEST_BUILD_DIR, "fruit_basket.f90")
INTEGRATION_TEST_DRIVER_SOURCE_FILE = File.join(INTEGRATION_TEST_BUILD_DIR, "fruit_driver.f90")
INTEGRATION_TEST_RESULTS_FILE = File.join(INTEGRATION_TEST_BUILD_DIR, "results.xml")

directory DEVEL_DIR
directory RELEASE_DIR
directory UNIT_TEST_BUILD_DIR
directory INTEGRATION_TEST_BUILD_DIR

task :default => :release

desc "Build the development version of all executables"
task :devel

desc "Build the release version of all executables"
task :release

desc "Run all tests"
task :test => [:unit_tests, :integration_tests]

desc "Run unit tests"
task :unit_tests do |task|
    task.sources.each do |program|
        sh program
    end
end

desc "Run integration tests"
task :integration_tests do |task|
    task.sources.each do |program|
        sh program
    end
end

desc "Analyze test coverage. Suggested to clear coverage data first to ensure accurate statistics"
task :coverage do |task|
    sh "gcov #{task.sources.join(" ")}"
    mv FileList["*.gcov"], DEVEL_DIR
end

desc "Clear coverage data"
task :clear_coverage do
    rm FileList[File.join(DEVEL_DIR, "*.gcda"), File.join(DEVEL_DIR, "*.gcov")]
end

sources, modules, _, programs = scanSourceFiles(findSourceFiles(["src"], [".f90"]), {})

unit_test_files = findSourceFiles(["unit_test"], [".f90"])
unit_test_files.push(File.join("fruit", "fruit.f90"))
unit_test_files.delete(UNIT_TEST_BASKET_SOURCE_FILE)
unit_test_files.delete(UNIT_TEST_DRIVER_SOURCE_FILE)
unit_test_collections = findSourceFiles(["unit_test"], ["_test.f90"])

unit_test_sources, unit_test_modules, modules_used_in_unit_tests, unit_test_programs = scanSourceFiles(unit_test_files, modules)

unit_test_basket_source = SourceFile.new(UNIT_TEST_BASKET_SOURCE_FILE)
unit_test_collections.each do |file|
    unit_test_basket_source.addModuleUsed(Pathname(file).basename.sub_ext("").to_s)
end
unit_test_basket_source.addModuleUsed("fruit")
unit_test_sources.push(unit_test_basket_source)
unit_test_modules["fruit_basket"] = Module.new("fruit_basket", unit_test_basket_source)

unit_test_driver_source = SourceFile.new(UNIT_TEST_DRIVER_SOURCE_FILE)
unit_test_driver_source.addModuleUsed("fruit_basket")
unit_test_sources.push(unit_test_driver_source)
unit_test_programs.push(Program.new("fruit_driver", unit_test_driver_source))

file UNIT_TEST_BASKET_SOURCE_FILE => UNIT_TEST_BUILD_DIR
file UNIT_TEST_BASKET_SOURCE_FILE => unit_test_collections do |task|
    createBasket(task.name, unit_test_collections)
end

file UNIT_TEST_DRIVER_SOURCE_FILE => UNIT_TEST_BUILD_DIR do |task|
    createDriver(task.name, UNIT_TEST_BASKET_SOURCE_FILE, UNIT_TEST_RESULTS_FILE)
end

integration_test_files = findSourceFiles(["integration_test"], [".f90"])
integration_test_files.push(File.join("fruit", "fruit.f90"))
integration_test_files.delete(INTEGRATION_TEST_BASKET_SOURCE_FILE)
integration_test_files.delete(INTEGRATION_TEST_DRIVER_SOURCE_FILE)
integration_test_collections = findSourceFiles(["integration_test"], ["_test.f90"])

integration_test_sources, integration_test_modules, modules_used_in_integration_tests, integration_test_programs = scanSourceFiles(integration_test_files, modules)
modules_used_in_tests = modules_used_in_unit_tests.concat(modules_used_in_integration_tests)

integration_test_basket_source = SourceFile.new(INTEGRATION_TEST_BASKET_SOURCE_FILE)
integration_test_collections.each do |file|
    integration_test_basket_source.addModuleUsed(Pathname(file).basename.sub_ext("").to_s)
end
integration_test_basket_source.addModuleUsed("fruit")
integration_test_sources.push(integration_test_basket_source)
integration_test_modules["fruit_basket"] = Module.new("fruit_basket", integration_test_basket_source)

integration_test_driver_source = SourceFile.new(INTEGRATION_TEST_DRIVER_SOURCE_FILE)
integration_test_driver_source.addModuleUsed("fruit_basket")
integration_test_sources.push(integration_test_driver_source)
integration_test_programs.push(Program.new("fruit_driver", integration_test_driver_source))

file INTEGRATION_TEST_BASKET_SOURCE_FILE => INTEGRATION_TEST_BUILD_DIR
file INTEGRATION_TEST_BASKET_SOURCE_FILE => integration_test_collections do |task|
    createBasket(task.name, integration_test_collections)
end

file INTEGRATION_TEST_DRIVER_SOURCE_FILE => INTEGRATION_TEST_BUILD_DIR do |task|
    createDriver(task.name, INTEGRATION_TEST_BASKET_SOURCE_FILE, INTEGRATION_TEST_RESULTS_FILE)
end

sources.each do |source|
    file source.object(DEVEL_DIR) => source.file_name do |task|
        compile_command = "#{COMPILER} -c -J#{DEVEL_DIR} #{FFLAGS} #{DEVEL_FLAGS}"
        if usedInTest(source, modules_used_in_tests)
            compile_command += " -coverage"
        end
        sh "#{compile_command} -o #{task.name} #{source.file_name}"
    end
    if usedInTest(source, modules_used_in_tests)
        file source.coverageSpec(DEVEL_DIR) => source.object(DEVEL_DIR)
        file source.coverageData(DEVEL_DIR) => [:unit_tests, :integration_tests]
        file source.coverageOutput(DEVEL_DIR) => :coverage
        task :coverage => source.coverageData(DEVEL_DIR)
    end
    file source.object(RELEASE_DIR) => source.file_name do |task|
        compile_command = "#{COMPILER} -c -J#{RELEASE_DIR} #{FFLAGS} #{RELEASE_FLAGS}"
        sh "#{compile_command} -o #{task.name} #{source.file_name}"
    end
    source.modules_used.each do |module_name|
        if modules.include?(module_name)
            file source.object(DEVEL_DIR) => File.join(DEVEL_DIR, "#{module_name}.mod")
            file source.object(RELEASE_DIR) => File.join(RELEASE_DIR, "#{module_name}.mod")
        end
    end
    file source.object(DEVEL_DIR) => DEVEL_DIR
    file source.object(RELEASE_DIR) => RELEASE_DIR
end

modules.each do |module_name, module_|
    file File.join(DEVEL_DIR, "#{module_name}.mod") => module_.source.object(DEVEL_DIR)
    file File.join(RELEASE_DIR, "#{module_name}.mod") => module_.source.object(RELEASE_DIR)
end

programs.each do |program|
    file File.join(DEVEL_DIR, "#{program.name}.exe") => followDependencies(program.source, DEVEL_DIR, modules) do |task|
        compile_command = "#{COMPILER} #{FFLAGS} #{DEVEL_FLAGS}"
        if containsTestedCode(program, modules_used_in_tests, modules)
            compile_command += " -coverage"
        end
        sh "#{compile_command} -o #{task.name} #{task.sources.join(" ")}"
    end
    task :devel => File.join(DEVEL_DIR, "#{program.name}.exe")
    file File.join(RELEASE_DIR, "#{program.name}.exe") => followDependencies(program.source, RELEASE_DIR, modules) do |task|
        compile_command = "#{COMPILER} #{FFLAGS} #{RELEASE_FLAGS}"
        sh "#{compile_command} -o #{task.name} #{task.sources.join(" ")}"
    end
    task :release => File.join(RELEASE_DIR, "#{program.name}.exe")
end

unit_test_sources.each do |source|
    file source.object(UNIT_TEST_BUILD_DIR) => source.file_name do |task|
        compile_command = "#{COMPILER} -c -J#{UNIT_TEST_BUILD_DIR} #{FFLAGS} #{DEVEL_FLAGS}"
        if usesProductionCode(source, modules)
            compile_command += " -I#{DEVEL_DIR}"
        end
        sh "#{compile_command} -o #{task.name} #{source.file_name}"
    end
    source.modules_used.each do |module_name|
        if modules.include?(module_name)
            file source.object(UNIT_TEST_BUILD_DIR) => File.join(DEVEL_DIR, "#{module_name}.mod")
        end
        if unit_test_modules.include?(module_name)
            file source.object(UNIT_TEST_BUILD_DIR) => File.join(UNIT_TEST_BUILD_DIR, "#{module_name}.mod")
        end
    end
    file source.object(UNIT_TEST_BUILD_DIR) => UNIT_TEST_BUILD_DIR
end

unit_test_modules.each do |module_name, module_|
    file File.join(UNIT_TEST_BUILD_DIR, "#{module_name}.mod") => module_.source.object(UNIT_TEST_BUILD_DIR)
end

unit_test_programs.each do |program|
    file File.join(UNIT_TEST_BUILD_DIR, "#{program.name}.exe") => followTestDependencies(program.source, UNIT_TEST_BUILD_DIR, DEVEL_DIR, unit_test_modules, modules) do |task|
        compile_command = "#{COMPILER} #{FFLAGS} #{DEVEL_FLAGS} -coverage"
        sh "#{compile_command} -o #{task.name} #{task.sources.join(" ")}"
    end
    task :unit_tests => File.join(UNIT_TEST_BUILD_DIR, "#{program.name}.exe")
end

integration_test_sources.each do |source|
    file source.object(INTEGRATION_TEST_BUILD_DIR) => source.file_name do |task|
        compile_command = "#{COMPILER} -c -J#{INTEGRATION_TEST_BUILD_DIR} #{FFLAGS} #{DEVEL_FLAGS}"
        if usesProductionCode(source, modules)
            compile_command += " -I#{DEVEL_DIR}"
        end
        sh "#{compile_command} -o #{task.name} #{source.file_name}"
    end
    source.modules_used.each do |module_name|
        if modules.include?(module_name)
            file source.object(INTEGRATION_TEST_BUILD_DIR) => File.join(DEVEL_DIR, "#{module_name}.mod")
        end
        if integration_test_modules.include?(module_name)
            file source.object(INTEGRATION_TEST_BUILD_DIR) => File.join(INTEGRATION_TEST_BUILD_DIR, "#{module_name}.mod")
        end
    end
    file source.object(INTEGRATION_TEST_BUILD_DIR) => INTEGRATION_TEST_BUILD_DIR
end

integration_test_modules.each do |module_name, module_|
    file File.join(INTEGRATION_TEST_BUILD_DIR, "#{module_name}.mod") => module_.source.object(INTEGRATION_TEST_BUILD_DIR)
end

integration_test_programs.each do |program|
    file File.join(INTEGRATION_TEST_BUILD_DIR, "#{program.name}.exe") => followTestDependencies(program.source, INTEGRATION_TEST_BUILD_DIR, DEVEL_DIR, integration_test_modules, modules) do |task|
        compile_command = "#{COMPILER} #{FFLAGS} #{DEVEL_FLAGS} -coverage"
        sh "#{compile_command} -o #{task.name} #{task.sources.join(" ")}"
    end
    task :integration_tests => File.join(INTEGRATION_TEST_BUILD_DIR, "#{program.name}.exe")
end

CLEAN.include(FileList[
    "build/devel/*",
    "build/release/*",
    "unit_test/build/*",
    "integration_test/build/*",
    ])
CLEAN.exclude(FileList[
    "build/devel/*.exe",
    "build/release/*.exe",
    "unit_test/build/*.exe",
    "integration_test/build/*.exe",
    ])

CLOBBER.include(FileList[
    "build",
    "unit_test/build",
    "integration_test/build",
    ])
