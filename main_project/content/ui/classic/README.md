# DFU scrollbar thumb slices

Unmodified `VScrollThumbTop.png`, `VScrollThumbBody.png` and
`VScrollThumbBottom.png` copied from pinned
`reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Resources/`.
Each is 5×1 pixels. Daggerfall Workshop copyright 2009–2023, MIT;
the upstream LICENSE is retained as DFU_LICENSE.txt.

SHA-256:

- Top: C2C54692B5FC4C81624A8D9A2BE07C0C7F954506031B26B99A41529CED0FA48B
- Body: 687A025521D817D34BF7A254A25ECE8B94CA3CEB91E22EBF6F908757C6FDEC21
- Bottom: FC2C0ED8F492AAFF9C7CB674514A53413EE7CDBE1A18208739193A453D078109

AV combines the slices in memory into a nearest-filtered 5×3 atlas. The optional
`creation.scrollbar-thumb` media target preserves normal replacement precedence;
the one-pixel top/bottom margins leave the original vertical bevel unscaled.
