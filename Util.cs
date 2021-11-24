using System;
using System.Linq;
using System.Collections.Generic;

public static class Util {
    public static bool InSequence(this IEnumerable<int> e) {
        for (int i = 0; i < e.Count() - 1; i++) {
            if (e.ElementAt(i) >= e.ElementAt(i + 1))
                return false;
        }
        return true;
    }
}