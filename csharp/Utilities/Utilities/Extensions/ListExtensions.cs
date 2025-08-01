namespace Utilities.Extensions;

public static class ListExtensions
{
    public static bool ContainsAllItems<T>(this IEnumerable<T> a, IEnumerable<T> b)
    {
        return !b.Except(a).Any();
    }
    
    public static int[] FindAllIndexes(this string[] array, string search) => array
        .Select((x, i) => (x, i))
        .Where(value => value.x == search)
        .Select(value => value.i)
        .ToArray();
    
    public static string[] GetItemsFromIndices(this string[] array, int[] indices) => array
        .Select((x, i) => (x, i))
        .Where(value => indices.Contains(value.i))
        .Select(value => value.x)
        .ToArray();
}
