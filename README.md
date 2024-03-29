<center>
	<h2>
		VE370 Intro to Computer Organization
	</h2>
</center> 
<center>
	<h3>
		Project 3
	</h3>
</center>

### Honor Code Disclaimer

If there is same questions or labs in the future, it is the responsibility of JI students not to copy or modify these codes, or TeX files because it is against the Honor Code. The owner of this repository doesn't take any commitment for other's faults.

According to the student handbook (2020 version),

> It is a violation of the Honor Code for students to submit, as their own, work that is not the result of their own labor and thoughts. This applies, in particular, to ideas, expressions or work obtained from other students as well as from books, the internet, and other sources. The failure to properly credit ideas, expressions or work from others is considered plagiarism.

### Teamwork Distribution

| Name                                            | Work                                                         |
| ----------------------------------------------- | ------------------------------------------------------------ |
| [Yihua Liu](https://github.com/yihuajack)       | Debug<br />sim1a.v, sim1b.v, sim2a.v, sim2b.v<br />Simulation results<br />memory.mem, random.cpp |
| [Yiqi Sun](https://github.com/TogetherWithYiQi) | cache1a.v<br />cache1b.v<br />cache2a.v                      |
| [Ruge Xu](https://github.com/schrodinger95)     | cache2b.v<br />memory.v<br />Debug cache1b.v*                |

\* The change log of cache1b.v is not complete.

*****

### Abstract

This project is used to help our VE370 Project 3 team work together. 

### Code Style

1. Please avoid meaningless combination of letters like `a` or `abc` when naming variables. Name of variable should be meaningful. 
2. Please try to put module parameters such as output variables in the front position.
3. Please add appropriate indentation and blank lines to your code.
4. Please add enough comments to help others understand your code.

### Git Usage

Here are some simple instructions about how to use `git`.

1. If you want to download the whole project, run following command.

```bash
git clone https://github.com/yihuajack/VE370_FA2020_P3.git
```

2. If you want add files to our local git project and remote git project on `github`, run following command.

```bash
# Firstly, plz avoid adding files to master branch on github directly. You can create your own branch locally and remotely.

git branch ayka-b1 # create my local branch. Here I name the branch as 'ayka-b1'. If you have already created a branch, you can jump to next command.

git checkout ayka-b1 # switch to 'ayka-b1' branch.

git add * # add all the files to local branch 'ayka-b1'.

git commit -m "update" # confirm to add files to local branch 'ayka-b1'

git push origin ayka-b1 # create branch 'ayka-b1' remotely on github and copy your the content on your local branch 'ayka-b1' to the remote 'ayka-b1'.
```

3. If you want to synchronize files on remote project on `github`, you should run:

```bash
git pull origin master # synchronize files on remote master branch.
git pull origin "you branch name" # the 'master' can be replaced by the name of the other branch created on remote project on github, then you can synchronize files on the specific remote branch.
```

### Reference

[1] Zheng, G., 2020. *Ve370 Introduction To Computer Organization Project 3*.

---------------------------------------------------------------

<center>
    UM-SJTU Joint Institute 交大密西根学院
</center>
