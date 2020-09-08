const axios = require('axios');
const fs = require('fs');
const ProgressBar = require('progress');
const AdmZip = require('adm-zip');
const fetch  = require('node-fetch');
const execSync = require('child_process').execSync;
module.exports = function(ctx) {
    
    return new Promise(function(resolve, reject) {
        // var config = {
        //     responseType: 'stream'
        // };
        
        let url = "https://developers.fyusion.com/ios/nVuynERBAhOCMxjKtarLPAJZvBlwoRGGmswZopVi/3.4.1/FyuseSessionTagging.framework.zip";

        var zipPath = `${ctx.opts.plugin.dir}/src/ios/Fyusion360.zip`;
        console.log(zipPath);
        var extractDestinationPath = `${ctx.opts.plugin.dir}/src/ios`;
        
        const fileStream = fs.createWriteStream(zipPath);

        process.stdout.write("Downloading Fyusion360 SDK zip file...");
        fetch(url).then((res) => {
            res.body.pipe(fileStream);
            res.body.on("error", (err) => {
                console.log(err);
                return reject(err);
            });
            res.body.on('close', (data) => {
                return resolve();
            });

            fileStream.on("finish", function() {
                var zip = new AdmZip(zipPath);

                process.stdout.write("Done\n");
                process.stdout.write('Extracting zip file contents....');
                zip.extractAllTo(extractDestinationPath, false);
                process.stdout.write('Done.\n');
                process.stdout.write("Removing zip file....");
                fs.unlink(zipPath, (err) => {
                    process.stdout.write("Done.\n")
                    return resolve();
                });
                process.stdout.write('Removing x86_64 from FyuseSessionTagging...\n');
                const frameworkPath = extractDestinationPath + '/3.4.1/FyuseSessionTagging.framework/FyuseSessionTagging';
                const output = execSync('lipo -remove x86_64 ' + frameworkPath + ' -o ' + frameworkPath, { encoding: 'utf-8' } );
                console.log(output);
                return resolve();
            });
        });       
    });
}