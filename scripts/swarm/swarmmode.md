# Swarm 模式

- 自从 1.12 版本, Docker Engine 嵌入了 SwarmKit

- 所有的 SwarmKit 特性处于未激活 "asleep" 直到你启动 "Swarm mode"

- Swarm 模式命令实例:

  - `docker swarm` (enable Swarm mode; join a Swarm; adjust cluster parameters)

  - `docker node` (view nodes; promote/demote managers; manage nodes)

  - `docker service` (create and manage services)

???

- The Docker API exposes 相同的概念

- The SwarmKit API is also exposed (on a separate socket)

---

## Swarm mode needs to be explicitly activated

- 默认, 所有的新代码处于未激活

- Swarm mode can be enabled, "unlocking" SwarmKit functions
  <br/>(services, out-of-the-box overlay networks, etc.)

.练习[

- Try a Swarm-specific command:

  ```bash
  docker node ls
  ```

<!-- Ignore errors: ```wait not a swarm manager``` -->

]

--

你将得到一个错误信息:

  ```bash
  Error response from daemon: This node is not a swarm manager. [...]
  ```
