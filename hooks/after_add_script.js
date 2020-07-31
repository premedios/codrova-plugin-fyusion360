const fs = require('fs');
const { exec } = require("child_process");

module.exports = function(ctx) {

    fs.readFile(`${ctx.opts.projectRoot}/platforms/ios/Podfile`, (error, data) => {
        if (error) {
            console.log(`Error: ${error}`);
        } else {
            console.log(typeof data);
            var dataString = data.toString('UTF8');
            var lines = dataString.split('\n');
            var searchLines = lines
            searchLines.some((line, index) => {
                console.log(line.search('\\tproject'));
                if (line.search('\\tproject') != -1) {
                    console.log(index);
                    lines.splice(index + 1, 0, `\tpod 'FyuseSessionTagging', podspec: 'https://developers.fyusion.com/FyuseSessionTagging/JVORXiVbgaosXiGkwjs_ZtMdTMEDhyQbPjWTcbzP/latest.podspec'`);
                }
                return (line.search('\\tproject') != -1);
            });
            console.log(lines.join('\n'));
            fs.writeFile(`${ctx.opts.projectRoot}/platforms/ios/Podfile`, lines.join('\n'), (data, error) => {
                if (error) {
                    console.log(`Error: ${error}`)
                } else {
                    var curDir = process.cwd();
                    process.chdir(`${ctx.opts.projectRoot}/platforms/ios`);
                    console.log(process.cwd());
                    exec("pod install", (error, stdout, stderr) => {
                        console.log(`stderr: ${stderr}`);
                        console.log(`stdout: ${stdout}`);
                        console.log(`error: ${error}`);
                        process.chdir(curDir);
                        console.log(process.cwd());
                    });
                }
            })
        }
    })
    // console.log(fs.readdirSync(`${ctx.opts.projectRoot}/platforms/ios`));
    // var curDir = process.cwd();
    // process.chdir(`${ctx.opts.projectRoot}/platforms/ios`);
    // console.log(process.cwd());
    // exec("pod install", (error, stdout, stderr) => {
    //     console.log(`stderr: ${stderr}`);
    //     console.log(`stdout: ${stdout}`);
    //     console.log(`error: ${error}`);
    //     process.chdir(curDir);
    //     console.log(process.cwd());
    // });

}