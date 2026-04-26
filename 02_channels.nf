#!/usr/bin/env nextflow

// To expand the logging to display one line per process call
// nextflow run 02_channels.nf -ansi-log false


params {
    //input: String = 'Hola mundo!'
    input: Path = 'data/greetings.csv'
}

process sayHello {

    input:
    val greeting

    // MUST use double quotes around the output filename expression (NOT single quotes),
    // naming files based on the input data itself is almost always impractical. The better way to generate dynamic filenames is to pass metadata to a process along with the input files
    output:
    path "${greeting}_output.txt"

    script:
    // to not overwrite the same output file
    """
    echo '${greeting}' > ${greeting}_output.txt
    """
}


workflow {

    main:

    //Channels are queues designed to handle inputs efficiently and shuttle them from one step to another in multi-step workflows, while providing built-in parallelism and many additional benefits.

    //craete a input channel
    // .of -> channel factory method that creates a channel from a list of values
    // greeting_ch = channel.of('hej', 'hola', 'bonjour')

    // view channel contents
    //greeting_ch = channel.of('hej', 'hola', 'bonjour').view()

    // create an array
    //greetings_array = ['hej', 'hola', 'bonjour']

    // create channel from array 
    // ERROR 
    //greeting_ch = channel.of(greetings_array).view()

    // greeting_ch = channel.of(greetings_array)
    //     .view { greeting -> "Before flatten: $greeting" }
    //     .flatten()
    //     .view { greeting -> "After flatten: $greeting" }

    // create channel from array (different channel factory method)
    //greeting_ch = channel.fromList(greetings_array)

    // flatten() unpacks every row+column but we want to split only into individual rows only, hence use map()
    // row[0] extract the first column (greeting) from each row
    greeting_ch = channel.fromPath(params.input)
        .view { csv -> "Before splitCsv: $csv" }
        .splitCsv()
        .view { csv -> "After splitCsv: $csv" }
        .map { row -> row[0] }
        .view { greeting -> "After map: $greeting" }


    // emit a greeting
    sayHello(greeting_ch)

    publish:
    first_output = sayHello.out
}

output {
    first_output {
        path 'hello_channels'
        mode 'copy'
    }
}