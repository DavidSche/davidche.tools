# JVM垃圾回收器

## Concurrent Mark and Sweep - CMS垃圾收集器

### 简介

CMS（Concurrent Mark and Sweep）是以牺牲吞吐量为代价来获得最短停顿时间的垃圾回收器，主要适用于对响应时间的侧重性大于吞吐量的场景。**仅针对老年代（Tenured Generation）的回收**。

[![Figure 1.3](http://www.informit.com/content/images/chap1_9780133796827/elementLinks/01fig03.jpg)](javascript:popUp('/content/images/chap1_9780133796827/elementLinks/01fig03_alt.jpg'))

为求达到该目标主要是因为以下两个原因：

1. 没有采取compact操作，而是简单的mark and sweep，同时维护了一个free list来管理内存空间，所以也产生了大量的内存碎片。
2. mark and sweep分为多个阶段，其中大部分的阶段的GC线程是和用户线程并发执行，默认的GC线程数为物理CPU核心数的1/4。

因为是并发地进行清理，所以必须**预留**部分堆空间给正在运行的应用程序，默认情况下在老年代使用了68%及以上的内存的时候就开始CMS。



### 过程

- 初始标记（initial mark）**Stop The World**

  ![CMS initial mark](https://plumbr.eu/wp-content/uploads/2015/06/g1-06.png)

  本阶段需要stop the world，一是标记老年代中所有的GC Roots所指的**直接对象**；二是标记被年轻代中存活对象引用的**直接对象**。因为仅标记少量节点，所以很快就能完成。

- 并发标记（concurrent mark）

  ![CMS concurrent marking](https://plumbr.eu/wp-content/uploads/2015/06/g1-07.png)

  在初始标记的基础上继续往下遍历其他的对象引用并进行标记，，该过程会和用户线程**并发**地执行，不会发生停顿。这个阶段会从initial mark阶段中所标记的节点往下检索，标记出所有老年代中存活的对象。注意此时会有部分对象的引用被改变，如上图中的current obj原本所引用的节点已经失去了关联。

- 并发预清理（concurrent preclean）

  ![CMS dirty cards](https://plumbr.eu/wp-content/uploads/2015/06/g1-08.png)

  前一个阶段在并行运行的时候，一些对象的引用已经发生了变化，当这些引用发生变化的时候，JVM会标记堆的这个区域为Dirty Card，这就是 Card Marking。

  ![CMS concurrent preclean](https://plumbr.eu/wp-content/uploads/2015/06/g1-09.png)

  在本阶段，那些能够从dirty card对象到达的对象也会被标记，这个标记做完之后，dirty card标记就会被清除了，如上图所示。

  总的来说，本阶段会**并发地**更新并发标记阶段的引用变化和查找在并发标记阶段新进入老年代的对象，如刚晋升的对象和直接被分配在老年代的对象。通过重新扫描，以减少下一阶段的工作。

- 可中止的并发预清理（concurrent abortable preclean）

  这个阶段尝试着去承担STW的Final Remark阶段足够多的工作。这个阶段持续的时间依赖好多的因素，由于这个阶段是重复的做相同的事情直到发生aboart的条件之一（比如：重复的次数、多少量的工作、持续的时间等等）才会停止。

- 重新标记 / 最终标记（final remark）**Stop The World**

  本阶段需要stop the world，通常来说此次暂时都会比较长，因为并发预清理是并发执行的，对象的引用可能会发生进一步的改变，需要确保在清理之前保持一个正确的对象引用视图，那么就需要stop the world来处理复杂的情况。

- 并发清理（concurrent sweep）

  ![CMS concurrent sweep](https://plumbr.eu/wp-content/uploads/2015/06/g1-10.png)

  使用标记-清除法回收**老年代**的垃圾对象，与用户线程并发执行。

- 并发标记重置（concurrent reset）

  清空现场，为下一次GC做准备。



## Garbage First - G1垃圾收集器

### 简介

G1收集器（或者垃圾优先收集器）的设计初衷是为了尽量缩短处理超大堆时产生的停顿。在回收的时候将对象从一个小堆区复制到另一个小堆区，这意味着G1在回收垃圾的时候同时完成了堆的部分内存压缩，相对于CMS的优势而言就是内存碎片的产生率大大降低。

![img](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/G1GettingStarted/images/slide9.png)

heap被划分为一系列大小相等的“小堆区”，也称为region。每个小堆区（region）的大小为1~32MB，整个堆**大致**要划分出2048个小堆区。