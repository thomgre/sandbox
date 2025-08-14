using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

namespace Utilities.Extensions;

    public static class StringExtensions
    {
        public static string ToSnakeCase(this string input)
        {
            if (string.IsNullOrEmpty(input)) { return input; }

            var startUnderscores = Regex.Match(input, @"^_+");
            return startUnderscores + Regex.Replace(input, @"([a-z0-9])([A-Z])", "$1_$2").ToLower();
        }

        public static string Truncate(this string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value)) return value;
            return value.Length <= maxLength ? value : value.Substring(0, maxLength);
        }

        public static string Left(this string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value)) return value;
            maxLength = Math.Abs(maxLength);

            return (value.Length <= maxLength
                   ? value
                   : value.Substring(0, maxLength));
        }

        public static string Right(this string value, int length)
        {
            return value.Substring(value.Length - length);
        }

        public static string PlainTextTruncate(this string input, int length)
        {
            string text = HtmlToPlainText(input);
            if (text.Length < length)
            {
                return text;
            }

            char[] terminators = { '.', ',', ';', ':', '?', '!' };
            int end = text.LastIndexOfAny(terminators, length);
            if (end == -1)
            {
                end = text.LastIndexOf(" ", length);
                return text.Substring(0, end) + "...";
            }
            return text.Substring(0, end + 1);
        }

        //From https://stackoverflow.com/a/16407272/5
        //TODO: Use a proper sanitizer, perhaps https://github.com/atifaziz/High5
        public static string HtmlToPlainText(this string html)
        {
            //const string tagWhiteSpace = @"(>|$)(\W|\n|\r)+<";//matches one or more (white space or line breaks) between '>' and '<'
            //const string stripFormatting = @"<[^>]*(>|$)";//match any character between '<' and '>', even when end tag is missing
            //const string lineBreak = @"<(br|BR)\s{0,1}\/{0,1}>";//matches: <br>,<br/>,<br />,<BR>,<BR/>,<BR />
            //var lineBreakRegex = new Regex(lineBreak, RegexOptions.Multiline);
            //var stripFormattingRegex = new Regex(stripFormatting, RegexOptions.Multiline);
            //var tagWhiteSpaceRegex = new Regex(tagWhiteSpace, RegexOptions.Multiline);

            //var text = html;
            ////Decode html specific characters
            //text = System.Net.WebUtility.HtmlDecode(text);
            ////Remove tag whitespace/line breaks
            //text = tagWhiteSpaceRegex.Replace(text, "><");
            ////Replace <br /> with line breaks
            //text = lineBreakRegex.Replace(text, Environment.NewLine);
            ////Strip formatting
            //text = stripFormattingRegex.Replace(text, string.Empty);

            return string.IsNullOrWhiteSpace(html) ? html : Regex.Replace(html, "<.*?>", string.Empty);
        }

        public static string RemoveSpecialCharacters(this string str)
        {
            var stringBuilder = new StringBuilder();
            foreach (char c in str)
            {
                if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '.' || c == '_')
                {
                    stringBuilder.Append(c);
                }
            }
            return stringBuilder.ToString();
        }

        public static string ReplaceLastOccurrence(this string source, string oldValue, string newValue)
        {
            int pos = source.LastIndexOf(oldValue);

            return pos == -1
                ? source
                : source.Remove(pos, oldValue.Length).Insert(pos, newValue);
        }

        public static string ComputeSha256Hash(this string rawData)
        {
            // Create a SHA256   
            using (SHA256 sha256Hash = SHA256.Create())
            {
                // ComputeHash - returns byte array  
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));

                // Convert byte array to a string   
                var builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }


        //compiled regex for performance boost.
        static readonly Regex _htmlRegex = new Regex(@" < (.|\n) *?>", RegexOptions.Compiled);

        public static string StripHTML(this string input)
        {
            //  return string.IsNullOrEmpty(input) ? input : _htmlRegex.Replace(input, string.Empty).Trim(); doesnt seem 2 work
            return string.IsNullOrEmpty(input) ? input : Regex.Replace(input, @"<(.|\n)*?>", String.Empty);

        }


        public static string ReplaceAt(this string str, string target, string replace)
        {
            int index = str.IndexOf(target);
            int length = target.Length;

            return str.Remove(index, Math.Min(length, str.Length - index))
                    .Insert(index, replace);
        }


        public static string RemoveLastAnchor(this string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            var links = Regex.Match(input, @"<a(.*?)>(.*?)</a>");
            if (links.Success && links.Groups.Count > 0)
            {
                var match = links.Groups[links.Groups.Count - 1];
                // remove last found anchor/link tag
                input = input.Replace(match.Value, String.Empty);
            }
            return input;
        }

        public static string Capitalize(this string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return string.Empty;
            }
            char[] a = input.ToCharArray();
            a[0] = char.ToUpper(a[0]);
            return new string(a);
        }
        
        public static string Base64Encode(this string plainText) 
        {
            var plainTextBytes = Encoding.UTF8.GetBytes(plainText);
            return Convert.ToBase64String(plainTextBytes);
        }
        
        public static string Base64Decode(this string base64EncodedData) 
        {
            var base64EncodedBytes =Convert.FromBase64String(base64EncodedData);
            return Encoding.UTF8.GetString(base64EncodedBytes);
        }
        
        public static string GenerateSlug(this string phrase) 
        { 
            string str = phrase.RemoveAccent().ToLower(); 
            // invalid chars           
            str = Regex.Replace(str, @"[^a-z0-9\s-]", ""); 
            // convert multiple spaces into one space   
            str = Regex.Replace(str, @"\s+", " ").Trim(); 
            // cut and trim 
            str = str.Substring(0, str.Length <= 45 ? str.Length : 45).Trim();   
            str = Regex.Replace(str, @"\s", "-"); // hyphens   
            return str; 
        } 

        public static string RemoveAccent(this string txt) 
        { 
            byte[] bytes = System.Text.Encoding.GetEncoding("Cyrillic").GetBytes(txt); 
            return System.Text.Encoding.ASCII.GetString(bytes); 
        }
    }
