# How to Iterate through a Java List

## How to Iterate through a Java List

There are numerous ways to ieterate through a List making use of the Java language. This post will list a number of examples on how you can iterate over an ArrayList containing the names of cities as String values.

Example 1: Classic For Loop
The Java For-loop is a control flow statement that allows us to iterate over each position of the List. This example determines the size of the list, and iterate over the positions, by incrementing a counter.

```java
public static void forLoop() {
List<String> cityList = new ArrayList<String>();

    cityList.add("Amsterdam");
    cityList.add("Rotterdam");
    cityList.add("The Hague ");
    cityList.add("Utrecht");

    for (int i = 0; i < cityList.size(); i++) {
        System.out.println(cityList.get(i));
    }
}
```

Example 2: Enhanced For Loop
The enhanced for loop is based on the same principle as the standard for loop, it is just written in a much simpler form. The end result is the example iterates over the list.
```java
public static void enhancedForLoop() {
List<String> cityList = new ArrayList<String>();

    cityList.add("Amsterdam");
    cityList.add("Rotterdam");
    cityList.add("The Hague ");
    cityList.add("Utrecht");

    for (String cityValue : cityList) {
        System.out.println(cityValue);
    }
}
```

Example 3: Iterator
The Iterator interface has taken the place of an Enumeration in the Java Collections Framework and allow us to iterate over a Collection or List.
```java
public static void iteratorLoop() {
List<String> cityList = new ArrayList<String>();

    cityList.add("Amsterdam");
    cityList.add("Rotterdam");
    cityList.add("The Hague ");
    cityList.add("Utrecht");

    Iterator<String> iterator = cityList.iterator();
    while (iterator.hasNext()) {
        System.out.println(iterator.next());
    }
}
```

Example 4: While Loop
The Java while loop is a control flow statement that allows us to execute commands a set of commands repeatedly until a given boolean condition is met. This allow us to ieterate over the list based on its size and a index that gets incremented.

```java
private static void whileLoop() {
List<String> cityList = new ArrayList<String>();
int listPosition = 0;

    cityList.add("Amsterdam");
    cityList.add("Rotterdam");
    cityList.add("The Hague ");
    cityList.add("Utrecht");

    while (listPosition < cityList.size()) {
        System.out.println(cityList.get(listPosition));
        listPosition++;
    }
}
```

Example 5: Lamda Functions
The forEach method within the Iterable Interface performs the given action for each element of the Iterable until all elements have been processed or the action throws an exception.


```java
private static void forEach() {
List<String> cityList = new ArrayList<String>();

    cityList.add("Amsterdam");
    cityList.add("Rotterdam");
    cityList.add("The Hague ");
    cityList.add("Utrecht");

    cityList.forEach(listValue -> {
        System.out.println(listValue);
    });
}
```

Example 6: Iterator & forEachRemaining method
The forEachRemaining method within the Iterator Interface performs the given action for each remaining element until all elements have been processed or the action throws an exception.

```java
private static void forEachRemaining() {
List<String> cityList = new ArrayList<String>();

    cityList.add("Amsterdam");
    cityList.add("Rotterdam");
    cityList.add("The Hague ");
    cityList.add("Utrecht");

    Iterator<String> iterator = cityList.iterator();
    iterator.forEachRemaining(System.out::println);
}
```

## Summary

Congratulations! You have successfully learned numerous ways you can itereate over a List in Java. Follow me on any of the different social media platforms and feel free to leave comments.