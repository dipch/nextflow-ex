#!/usr/bin/env nextflow

params {
    input: Path = 'data/greetings.csv'
    batch: String = 'batch'
}

process sayHello {
    input:
    val greeting

    output:
    path "${greeting}-output.txt"

    script:
    """
    echo '${greeting}' > '${greeting}-output.txt'
    """
}

process convertToUpper {
    input:
    path input_file

    output:
    path "UPPER-${input_file}"

    script:
    """
    cat '${input_file}' | tr '[a-z]' '[A-Z]' > 'UPPER-${input_file}'
    """
}

process collectGreetings {
    input:
    path input_files
    val batch_name

    output:
    // path "COLLECTED-output.txt"
    path "COLLECTED-${batch_name}-output.txt", emit: outfile
    path "${batch_name}-report.txt", emit: report
    
    script:
    count_greetings = input_files.size()
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    echo 'There were ${count_greetings} greetings in this batch.' > '${batch_name}-report.txt'
    """
}

workflow {

    main:
    // create a channel for inputs from a CSV file
    greeting_ch = channel.fromPath(params.input)
        .splitCsv()
        .map { line -> line[0] }
    // emit a greeting
    sayHello(greeting_ch)
    // convert the output to uppercase
    convertToUpper(sayHello.out)
    // combine outputs
    // order should be same as the order of inputs in the process definition
    collectGreetings(convertToUpper.out.collect(), params.batch)

    //debug/log
    convertToUpper.out.view { contents -> "before collect: ${contents}" }
    convertToUpper.out.collect().view { contents -> "after collect: ${contents}" }

    publish:
    first_output = sayHello.out
    second_output = convertToUpper.out
    collected = collectGreetings.out.outfile
    report = collectGreetings.out.report
}

output {
    first_output {
        path 'hello_workflow'
        mode 'copy'
    }
    second_output {
        path 'hello_workflow'
        mode 'copy'
    }
    collected {
        path 'hello_workflow'
        mode 'copy'
    }
    report {
        path 'hello_workflow'
        mode 'copy'
    }
}
