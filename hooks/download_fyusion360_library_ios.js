const axios = require('axios');
const fs = require('fs');
const ProgressBar = require('progress');
const AdmZip = require('adm-zip');
const fetch  = require('node-fetch');

module.exports = function(ctx) {
    return new Promise(function(resolve, reject) {
        var config = {
            responseType: 'stream'
        };
        
        let url = "https://developers.fyusion.com/ios/JVORXiVbgaosXiGkwjs_ZtMdTMEDhyQbPjWTcbzP/3.3.0/FyuseSessionTagging.framework.zip";

        var zipPath = `${ctx.opts.plugin.dir}/src/ios/Fyusion360.zip`;
        console.log(zipPath);
        var extractDestinationPath = `${ctx.opts.plugin.dir}/src/ios`;
        
        const fileStream = fs.createWriteStream(zipPath);

        const downloadFile = (async (url, path) => {
            const res = await fetch(url);
            const fileStream = fs.createWriteStream(path);
            await new Promise((resolve, reject) => {
                res.body.pipe(fileStream);
                res.body.on("error", (err) => {
                    return reject(err);
                });
                res.body.on('close', (data) => {
                    return resolve();
                });

                fileStream.on("finish", function() {
                    var zip = new AdmZip(zipPath);
                    var entries = zip.getEntries();
                    var entryToExtract;
                    var found = false
                    entries.forEach(entry => {
                        if (entry.entryName.includes("framework") && !found) {
                            entryToExtract = entry;
                            found = true
                        }
                    });
                    
                    if (found) {
                        process.stdout.write('Extracting zip file contents....');
                        zip.extractEntryTo(entryToExtract, extractDestinationPath);
                        process.stdout.write('Done.\n');
                        process.stdout.write("Removing zip file....");
                        fs.unlink(zipPath, (err) => {
                            process.stdout.write("Done.\n")
                            return resolve();
                        });
                    } else {
                        return reject('No framework found in zip file');
                    }
                    resolve();
                });
            });
        });

        fetch(url).then((res) => {
            res.body.pipe(fileStream);
            res.body.on("error", (err) => {
                return reject(err);
            });
            res.body.on('close', (data) => {
                return resolve();
            });

            fileStream.on("finish", function() {
                var zip = new AdmZip(zipPath);
                var entries = zip.getEntries();
                var entryToExtract;
                var found = false
                entries.forEach(entry => {
                    if (entry.entryName.includes("framework") && !found) {
                        entryToExtract = entry;
                        found = true
                    }
                });
                
                if (found) {
                    process.stdout.write('Extracting zip file contents....');
                    zip.extractEntryTo(entryToExtract, extractDestinationPath);
                    process.stdout.write('Done.\n');
                    process.stdout.write("Removing zip file....");
                    fs.unlink(zipPath, (err) => {
                        process.stdout.write("Done.\n")
                        return resolve();
                    });
                } else {
                    return reject('No framework found in zip file');
                }
                resolve();
            });
        });

        //return downloadFile(url, zipPath);

        // axios.get(url, config).then(function(response) {
        //     const totalLength = response.headers['content-length'];

        //     const progressBar = new ProgressBar('-> downloading Fyusion360 Library zip [:bar] :percent :etas', {
        //         width: 40,
        //         complete: '=',
        //         incomplete: ' ',
        //         renderThrottle: 1,
        //         total: parseInt(totalLength)
        //     });

        //     response.data.on('data', (chunk) => {
        //         progressBar.tick(chunk.length)
        //     });

        //     response.data.on('close', (data) => {
        //         var zip = new AdmZip(zipPath);
        //         var entries = zip.getEntries();
        //         var entryToExtract;
        //         var found = false
        //         entries.forEach(entry => {
        //             if (entry.entryName.includes("framework") && !found) {
        //                 entryToExtract = entry;
        //                 found = true
        //             }
        //         });
                
        //         if (found) {
        //             process.stdout.write('Extracting zip file contents....');
        //             zip.extractEntryTo(entryToExtract, extractDestinationPath);
        //             process.stdout.write('Done.\n');
        //             process.stdout.write("Removing zip file....");
        //             fs.unlink(zipPath, (err) => {
        //                 process.stdout.write("Done.\n")
        //                 return resolve();
        //             });
        //         } else {
        //             return reject('No framework found in zip file');
        //         }
        //     })
        //     response.data.pipe(fs.createWriteStream(zipPath));
        // });

        
    });
}