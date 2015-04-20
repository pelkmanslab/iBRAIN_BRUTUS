DEP
===

DEP stands for `DEPloyed code`.  It is a repository for deployed code developed
and maintained by members of Lucas Pelkmans' lab http://www.pelkmanslab.org

Repository is designed to host only very well tested, stable and reliable code
that is deployed on HPC sites like Brutus Cluster, etc.


How to obtain a copy of repository
----------------------------------

git clone https://code.pelkmanslab.org/git/dep

or 

git clone pgcode:~/git/dep

After the repository is cloned run:

make init 

to update the linked sub-repositories.


How to deploy code into the repository
--------------------------------------

1) Copy all the files of interest keeping the folder structure from the main
lab repository (https://code.pelkmanslab.org/svn/trunk/pelkmans) into the 
repository copy located at:

<camelot_share_2>/Data/Code/dep

Alternatively you can maintain your own copy of repository with r/w access,
i.e. using pgcode see 
https://pelkmanslab.org/wiki/index.php/VCS_Repositories#SSH-based_access_to_git_repositories

2) (Optional) stage and commit new changes (files) using `git add -i` and 
`git commit` commands.
 
3) Write a short email to <yauhen.yakimovich@uzh.ch> with subject `dep`
and a copy of your commit log describing the changes as a body text.




Feedback
--------

For rules and further instruction visit:

https://www.pelkmanslab.org/wiki/index.php/VCS_Repositories#General_Lab_repository

or contact yauhen.yakimovich@uzh.ch

