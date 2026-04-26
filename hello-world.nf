#!/usr/bin/env nextflow

// run
// nextflow run hello-world.nf
// with input
// nextflow run hello-world.nf --input "hej hej"
// with resume
// nextflow run hello-world.nf --input "hej hej" -resume

// nextflow run hello-world.nf -output-dir myresults


// params block should be defined at the top before any process/workflow definition
// for default value initialization
params {
    //name: Type = default_value. 
    //Supported types include String, Integer, Float, Boolean, and Path.
    // if used -- input in command line, it will override the default value.
    // without default value(will need command line input)   input: String
    input: String = "hello world"
}



//The process definition starts with the keyword process, followed by the process name and finally the process body delimited by curly braces. The process body must contain a script block which specifies the command to run, which can be anything you would be able to run in a command line terminal.
process sayHello {

    // process level output not recommended, publishDir will be deprecate. use workflow-level publish block instead. 
    // publishDir 'results/hello_world', mode: 'copy'

    input:
    val greeting

    output:
    path 'output.txt'

    script:

    //The $ symbol and curly braces ({ }) tell Nextflow this is a variable name that needs to be replaced with the actual input value (=interpolated). The curly braces ({ }) were technically optional in previous versions of Nextflow,
    """
    echo '${greeting}' > output.txt
    """
}


//The workflow definition starts with the keyword workflow, followed by an optional name, then the workflow body delimited by curly braces. the workflow typically contains multiple calls to processes connected by channels, and the processes expect one or more variable input(s).
workflow{

    //Technically the main: line is not required for simple workflows like this, so you may encounter workflows that don't have it. But we'll need it for taking advantage of workflow-level outputs, so we might as well include it from the start.

    main:
    // emit a greeting
    // sayHello('hello world')

    // nextflow run hello-world.nf --input "hej hej"
    // Parameters that apply to a pipeline always take a double hyphen (--).
    // Parameters that modify a Nextflow setting, e.g. the -resume feature we used earlier, take a single hyphen (-).
    // params.<parameter_name>
    sayHello(params.input)

    publish:
    // publish the output to the current directory
    first_output = sayHello.out
}

output{
    first_output{
        // will save reults in ./results
        // path '.'

        // will save results in ./results/hello-world
        path 'hello-world'
        mode 'copy'
    }
}


// 
// nextflow log
// delete old work directories:
// Look up the most recent successful run where -resume wasn't used
// nextflow log
// preview directories that ll be cleaned
// nextflow clean -before <RUN_NAME> -n
// clean the directories
// nextflow clean -before <RUN_NAME> -f