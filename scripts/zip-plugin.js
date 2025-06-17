const fs = require("fs");
const path = require("path");
const archiver = require("archiver");

// Create output stream
const output = fs.createWriteStream(
  path.join(__dirname, "..", "Unearthed.koplugin.zip")
);
const archive = archiver("zip", {
  zlib: { level: 9 }, // Sets the compression level
});

// Listen for all archive data to be written
output.on("close", function () {
  console.log("Plugin has been zipped successfully!");
  console.log("Total bytes:", archive.pointer());
});

// Handle warnings and errors
archive.on("warning", function (err) {
  if (err.code === "ENOENT") {
    console.warn("Warning:", err);
  } else {
    throw err;
  }
});

archive.on("error", function (err) {
  throw err;
});

// Pipe archive data to the file
archive.pipe(output);

// Add the entire src directory to the root of the zip
const srcDir = path.join(__dirname, "..", "src");
archive.directory(srcDir, false);

// Finalize the archive
archive.finalize();
