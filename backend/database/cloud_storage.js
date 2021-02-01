const azure = require('@azure/storage-blob');
const BlobServiceClient = azure.BlobServiceClient;
const StorageSharedKeyCredential = azure.StorageSharedKeyCredential;

const azureData = require('../cert/config').azureData;

const sharedKeyCredential = new StorageSharedKeyCredential(azureData.account,azureData.accountKey);
const blobServiceClient = new BlobServiceClient(
    `https://${azureData.account}.blob.core.windows.net`,
    sharedKeyCredential
);

async function uploadFile(destPath,destName,srcFilePath) {
    const containerClient = blobServiceClient.getContainerClient("dishtodoor");
    const blobClient = containerClient.getBlobClient(destPath+destName);
    const blockBlobClient = blobClient.getBlockBlobClient();
    const res = await blockBlobClient.uploadFile(srcFilePath);
    return blockBlobClient.url;
}

// returns a promise of the upload
exports.uploadCookDishPic = function uploadCookDishPic(destName,picPath) {
    return uploadFile('cookdish_pics/',destName,picPath);
}