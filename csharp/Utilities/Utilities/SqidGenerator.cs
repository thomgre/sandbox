using Sqids;

namespace Utilities;

public class SqidGenerator
{
    private readonly SqidsEncoder<uint> _sqids;
    
    public SqidGenerator()
    {
        _sqids = new SqidsEncoder<uint>();
    }
    
    public string GenerateFromGuid(Guid guid)
    {
        byte[] bytes = guid.ToByteArray();
        uint[] integers = new uint[4];
        
        for (int i = 0; i < 4; i++)
        {
            integers[i] = BitConverter.ToUInt32(bytes, i * 4);
        }
        
        return _sqids.Encode(integers);
    }
    
    public Guid DecodeToGuid(string sqid)
    {
        uint[] integers = _sqids.Decode(sqid).ToArray();
        if (integers.Length != 4)
            throw new ArgumentException("Invalid Sqid for Guid conversion");
        
        byte[] bytes = new byte[16];
        for (int i = 0; i < 4; i++)
        {
            byte[] intBytes = BitConverter.GetBytes(integers[i]);
            Array.Copy(intBytes, 0, bytes, i * 4, 4);
        }
        
        return new Guid(bytes);
    }    
}
