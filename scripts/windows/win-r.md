# 最绿色最高效，用win+r启动常用程序和文档

win+run启动常用程序和文档　　真正的高手，是普通招式发挥出大威力，是根据情况选用最合适的招法，是从繁芜的武学中跳得出来。软件之道亦然。固然要选佳软，但更须善用。软件再好， 也是开发者之功；而运用之妙存乎一心，才是属于用户。在快速启动程序的工具软件中，精品辈出。有TypeAndRun、SlickRun这样的旧日经典， 有Launchy这样的潮流新秀，也有人所罕知但异常强大的FARR。但善用佳软和很多网友却从不用此类工具，而是巧用最朴素的win+r方式。与大家分享如下。
　　本文可概括为一句话：“建立.lnk，改名.lnk以便于记忆和输入，集中lnk到某目录，加此目录到path变量”。如果全明白就不用往下看了。如果很不明白，也别担心。下文很详细，由浅入深，无论何种水平，都保证学会。

目录
-入门篇：
　　1. win+r 示例
　　2. 体验：最简单方法（初级）
　　3. 总结：win+r 四大优势
-进阶篇：
　　4. 学习：最标准的做法（中级1）
　　5. 原理：知其所以然（中级2）
-高级篇：
　　6. 高级应用及扩展知识更新
　　7. 总结

## 1. win+r 示例
　　win+r，有意义的读法应该是 win+run，表示同时按下windows键 [注] 和r键（据说Vista中只要按win即可），等同于开始菜单的“运行”。注意，只是效果等同，从速度来看，按win+r比用鼠标要快很多倍。用win+r启动常用程序，1秒钟足矣。
　　比如，笔者要打开MS Office Word程序时，一共只要按下4个键：win+r, w enter，一秒钟足矣。基本上，笔者启动任何常用软件，都是这种win+r, xx, enter模式，按键最少4个，多也不超过个6个。其中的xx就相当于软件的缩写，比如我常用的有：

ooo=OpenOffice， wps=wps，
xls=MS Excel，ppt=MS PowerPoint，doc=MS Word
m=Maxthon，fx=Firefox，fx3=Firefox3，o=Opera，ie=浏览器IE, chrome=浏览器Chrome
tc=Total Commander，tb=Thunderbird， iv=IrfanView
wn=工作笔记（WorkNote.txt），pn=个人笔记（Private Note），addr=通讯录文件， id=常用id及密码
5=酷极五笔……
ahk=默认的ahk脚本
ev=启动everything
en=启动Evernote
fm=FreeMind
myip bj=北京办公室的IP及代理设置; myip no=取消代理

　　启动常用的软件、打开常用的文档或目录、访问常用的网页，甚至完成任何重复性工作——这一切操作，都可以用win+r快速开始。

## 2. 体验：最简单方法（初级）
　　这么神奇的win+r，并且可以这样个性化，是不是很复杂呢？绝不是。真正的好方法，是可以满足用户的多种需求，但又是很简单的。只须2步，就能体验到win+r之简，之便，之实用。
　　步骤1：相信你最常用的程序或游戏，在桌面上已经有快捷方式了。那就选择其中的一个，并它的名字改短一些，最好是1-3个字母。比如，把Word快捷方式改为w，或把某游戏快捷方式改为yx（就是游戏的汉语拼音缩写啊）。
　　步骤2：把改名后的桌面图标复制（或移动）到 c:/windows 目录下。
　　现在试一试 win+r w，或win+r yx，是不是大功告成了呢！
　　[注]：如果输入w之后，自动填充了 www.abcdef.com 这样的网址，请参见注释 [1] 进行解决。

## 3. 小结：win+r 四大优势
　　现在你已经掌握了win+r方法。它具有如下特点：
　　最绿色。如果使用类似功能的软件，即便不要安装，也总要复制解压；即便再小巧，也会占用硬盘空间（或者，有时候不是硬盘空间的问题，而是软件数量过 多，看起来管起来都不方便）；再省资源，也要长期驻留内存，占用一定资源，甚至出现在系统托盘图标中。而win+r模式，则是真正的零成本、零占用，是使 用操作系统的自带功能。说win+r最绿色不会有人反对吧？你反对？它已经超越了绿色，达到了无色的境界？同意。
　　最快捷。不再需要鼠标，不再需要切换界面，不再需要进入层层菜单，甚至不需要睁着眼睛，只要1秒钟，按下几个键，程序就启动了。甚至比你说“芝麻开门” 用的时间还短。
　　最稳定。还用说吗？装的软件越少，系统当然越稳定。最简单，当然bug就最少。
　　最人性。它不会象一般热键工具那样，限定你“单字母+特殊键(alt/shift/ctrl)”这种极不便于记忆的方式，而是改用普通字符串，可以由你自由命名。比如一个MS Word，喜欢简洁者可命名为w；如果w已被占用（比如Wink），可称为doc；如果你很有才，也可以称为“微软帮我来写字”——没错，可以是中文！这种自由的命名方式，在遇到多个程序缩写接近，或一个软件的多个版本时，处理起来很自由。
　　因此，我极力宣传win+r模式。一方面，它让桌面和快速启动栏不再拥挤，让程序和文档启动更加快捷，而不需要安装专门启动软件。另一方面，这个例子以小见大，让我们看到善用系统标准功能的新思路。
　　当然，win+r方法在智能化方面，比专门工具还有很大差距。所以，它并不是以相同的功能代替专门软件，而是以新风格提供另一种选择。是否选用，用户自行决定，可参见《总结: 快速启动程序和文档的好软件》。

## 4. 学习：最标准的做法（中级1）
　　上面是最简单的做法，适合要求少、对快捷方式无须过多管理的用户。如果你希望有更深入的应用和了解，则我推荐下面的标准4步法。

步骤1：找到目标，为它建立快捷方式。
　　上例的桌面图标，以及开始菜单、快速启动栏，很多已经是快捷方式。但对于更多的程序、文档、目录，你要掌握手工建立快捷方式的做法。也很简单，在资源管理器中右键点击它，在弹出菜单上选“发送到→桌面快捷方式”或“创建快捷方式”。
　　
步骤2：为快捷方式改名
　　如何改名，大家都应该都会了（F2）。我只推荐一些原则。
　　最根本的原则就是适合自己。比如，你记性好但键盘慢，则尽量让名称短一些，比如只用一个字母。如果你不在乎打字速度，一心装酷给别人看，则完全可以把notepad.exe快捷方式改为“我现在要打字了！！”。再如选择拼音缩写，还是英文缩写等。
　　最常用的保持最短，比如单字母（word→w）。次常用的可以多几个字母（wink→w被占用，就用wink，或wi）。
　　用文件名后缀作缩写是个好办法。word→doc， powerpoint→ppt……
　　多版本只需要加数字或其他标识。比如fx2=Firefox v2.0，fx3=Firefox 3beta。再如tc=Total Commander官方原版，tcz=Total Commander张学思版，tcee=TC shanny版……
　　
步骤3：快捷方式移到专门目录
　　比如，我把这些快捷方式都移动到目录d:\short，这样方便管理。有些快捷方式当时常用，过了一段时间就不用了，可以不定期查看一下，及时清理无用信息。
　　其实，步骤2和步骤3没有先后顺序。
　　
步骤4：专门目录加入系统path变量
　　什么是path（路径）？举例来说，用户是让操作系统运行notepad，操作系统就需要到“某些目录”下寻找notepad文件。这些目录的设定，就是path变量的值。因此，我们要在path中加入专门存放快捷方式的 d:\short 目录。
　　如何修改path变量？方式有很多，比如修改注册表。中级用户推荐手工做法：“桌面→ 我的电脑→右键菜单→属性→高级→环境变量→用户变量 或 系统变量→path”。
　　具体做法：选中path后，点击“编辑”，在弹出的对话框中，“变量值”输入框中，定位到文字最后面（可按End键），先添加一个半角分号（以表示与前面的内容区分），再写入（分号后面不用空格）d:\short\ 即可（注意short后面要有反斜线）。
　　特别提醒：修改path变量后不会立即生效，需要重启（或注销）计算机，或重新启动explorer进程。向普通用户推荐注销的做法。
　　录屏演示：为帮助读者更容易理解，故提供录屏演示如下。注意：录屏中输入目录为 d:\path\，按本文内容，应该为 d:\short\ 。
win+r加入路径动画演示 gif格式

## 5. 原理：知其所以然（中级2）
　　当用户按下win+r xyz enter时，一无所知的计算机面对xyz，是这样思考并行动的。
　　① 查系统变量path，得到多个目录，比如 C:\WINDOWS\system32; C:\WINDOWS; C:\WINDOWS\System32\Wbem; d:\short; d:\ProgramFiles……
　　② 依次搜索上面的目录，找是否有叫作 xyz.cmd, xyz.exe, xyz.bat, xyz.lnk的文件。（实际还会到注册表中找相关信息）
　　③ 从 d:\short 发现了 xyz.lnk
　　④ 从 xyz.lnk 中，找到真正要运行的文档或程序的位置，比如 d:\Program Files\tc7.0\TOTALCMD.EXE，以及其他信息（比如窗口是否最大化等）
　　⑤ windows启动真正的目标文档或程序
　　
　　补充1：.lnk文件到底是什么？关于.lnk文件的详细解释，可见（英文）http://filext.com/file-extension/LNK 。要想直观体验，你可以右键点击一个lnk文件，在弹出菜单上选“属性”。其实从属性中，看到的就是它的全部内容。如果你觉得这不算是查看文件，也可以试着用记事本打开.lnk，多少也能有点认识，但请不要用记事本修改或保存。
　　
　　补充2：重名的问题。因为win+r xxx并不等同于 d:\short\xxx.lnk，所以，应该尽量避免缩写重名。比如，win+r cmd 对 d:\short\cmd.lnk是不起作用的，因为 cmd 会优先对应到 c:\WINDOWS\system32\cmd.exe。到于其具体优先级，一方面与全局变量、用户变量的path先后顺序相关，也与后缀的优先级相关，也与注册表相关，我无力分析，只建议用户避开系统已有的缩写，比如，为lnk缩写加数字，或再补充几个字母，以避开系统名称。
　　
　　附：静羽网友对优先级的补充：
　　“5. 原理：知其所以然（中级2）” 这块还有待细化。存在这样一个问题，比如，几个不同系统变量path里都含有一个相同名称的快捷方式，启动顺序是怎样的呢？将这个问题具体化，我们做一个试验：将D盘的任意文件建立一快捷方式，重命名为notepad，放到用户名目录下（eg：C:\Doduments and Settings\Administrator),然后WIN+R，输入notepad，回车，你会发现启动的并不是记事本，而是你刚才建立快捷方式的那个文件。由此可见，这种方式启动程序时，默认并不是最先从系统目录下开始。
　　这是由以前在网上看到的一篇关于WIN+R内核解密修改而来。关于启动顺序的优先级问题，我还没来得及仔细研究，但是可以根据前面的方法，在不同变量path，给不同文件设置相同的快捷方式名来验证。在此仅供参考。

## 6. 高级应用及扩展知识
### 6.1 快速切换ip地址
　　对于经常切换IP 地址的网友来说，这一技巧极其实用。我如果出差到了上海，只要 win+r ip sh 即可；回到北京，再按一下 win+r ip bj 就好了。如何实现，见《用批处理快速切换IP》。

### 6.2 快速访问网址URL
　　不仅是程序和文档可以快速访问，网址也是可以的。比如，键入 win+r xbeta 就直接访问 http://xbeta.info 。但是，做法上稍有不同。

方法一：从 .url 到 .lnk
　　Windows中，只能对本地文件——无论是exe，还是doc、txt、html——建立.lnk链接。并不能直接对 http://xbeta.info 这样的url建立 .lnk 快捷方式。我们需要借助“网页的本地快捷方式”来中转一下，即第1步：先建立一个本地 .url 文件。方法很简单：在浏览器（比如IE）中，打开一个网页（如 http://blog.xbeta.info ），然后，菜单“文件→发送→桌面快捷方式”。这样桌面多了一个“善用佳软”链接，实际是”善用佳软.url”文件，本质就是文本文件。用Notepad打开，可以看到：

[DEFAULT]
BASEURL=http://xbeta.info/
[InternetShortcut]
URL=http://xbeta.info/
Modified=00D16061FE3EC90198
IconFile=http://xbeta.info/favicon.ico
IconIndex=1

　　如果把这个文件直接放到 path指定的目录下，是不能“win+r 善用佳软”直接运行的。原因是windows只查找名为“善用佳软”，以.lnk, .exe, .com等后辍结尾的文件，并不会试图匹配 善用佳软.url 。（当然，你可以win+r 善用佳软.url 来运行，但这样，即便改名为 x.url 也要输入5个字符，不够精简） 因此，第2步：为 .url 创建 .lnk 快捷方式。

　　但问题在于，你用常规建立快捷方式的做法，得到的会是“善用佳软.url”的复件，而不是.lnk文件。错不在你， 而在于windows自做聪明的认为：“.url就是网页的快捷方式啊。为什么一定要建立lnk呢？这个用户可能有问题。那就再复制一个url吧。反正在桌面上又不显示后缀，用户不会发现的……”——多说一句，这就是windows的典型思路，把它认为的通常情况当作绝对情况来默认处理，而并不提供特殊情况的解决方法。这一做法让初级用户感到方便，却让很多个性化用户很反感。
　　
　　如何才能为.url建立.lnk呢？
　　对Total Commander用户而言，根本不存在上面的问题。也就是说，TC用户可以直接选中 善用佳软.url，然后Ctrl+Shift+F5，就创建了真正能用的 善用佳软.lnk。笔者就是使用Total Commander的，所以此前从未意识到这是个问题，经网友提示，才补充了这部分内容。
　　使用资源管理器的用户无法直接创建lnk，因此可以换一种思路：修改已有的lnk文件。还不明白的，请下载查看flash教程 http://ishare.iask.sina.com.cn/f/10723000.html 。

方法二：把url作为浏览器快捷方式的参数
比如，chrome.lnk 目标值为 D:\soft\chrome-win32\chrome.exe 时，只启动浏览器Chrome。
把目标值改为 D:\soft\chrome-win32\chrome.exe http://xbeta.info ，这时就会启动Chrome并打开 xbeta.info 了。

### 6.3 快速而自动完成系列操作：win+r结合AHK
　　比如，可以按下 win+r gm，就会自动打开浏览器，自动进入gmail网页，自动输入用户名、密码，进入了Gmail信箱。
再举善用佳软在工作中实际用的2例。win+r n，则自动打开Lotus Notes，自动输入密码，进入了公司邮箱。win+r mock，则自动打开SAP，自动连结mock环境，自动输入用户名密码，进入了SAP 回归测试系统。这些自动操作都是借助一款神奇的小软件，AutoHotkey完成的，如何实现，详见《AutoHotkey 0 级入门教程:让重复工作一键完成》。

## 7. 总结
　　追求高效率的工作方法，并不意味着用大量“高级”软件，而是把很多基本功能运用好，贯通融合，来满足“真正的需求”。也就是说，善用比佳软更重要。（完）

## 附：注释
　　[1]: win+r后输入缩写时，系统会自动把历史记录给填充到输入框中。尤其是w开头的命令，很容易匹配 www.abcde.com 这样的网址。目前相对可行的方法是，在 IE浏览器→ 菜单“工具” → internet选项 → 高级 → 禁用“使用直接插入自动完成功能” （IE6图）。这样设置后，就会只提示，不填充。(鸣谢 威海推拉门)


