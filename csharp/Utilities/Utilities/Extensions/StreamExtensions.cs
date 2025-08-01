namespace Utilities.Extensions;

public static class StreamExtensions
{
    public static async Task<byte[]> ToByteBuffer(this Stream stream, int count, int bufferSize, int resetPosition)
    {
        var buffer = new byte[bufferSize];
        
        int bytesRead;
        do
        {
            bytesRead = await stream.ReadAsync(buffer, 0, bufferSize);
        } while (bytesRead > 0);

        stream.Seek(resetPosition, SeekOrigin.Begin);
        return buffer;
    }
}
