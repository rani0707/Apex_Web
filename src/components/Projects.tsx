'use client';

import { useState } from 'react';
import { ArrowUpRight } from 'lucide-react';
import styles from './Projects.module.css';
import type { Project } from '@/lib/fetchers';
import { sanitizeExternalUrl } from '@/lib/url';

interface Props {
  projects: Project[];
}

const categories = ['전체', 'AI', '보안', '개발'] as const;
type Category = (typeof categories)[number];

export default function Projects({ projects }: Props) {
  const [active, setActive] = useState<Category>('전체');

  const filtered = active === '전체'
    ? projects
    : projects.filter((p) => p.category === active);

  const safeUrlFor = (raw: string) => sanitizeExternalUrl(raw);

  return (
    <section id="projects" className={styles.section}>
      <div className={styles.container}>
        <div className={styles.sectionHead}>
          <div className={styles.label}>03 / PROJECTS</div>
          <h2 className={styles.title}>진행 중인 프로젝트</h2>
          <p className={styles.subtitle}>
            실제로 동작하는 프로젝트들을 통해<br />
            실전 역량을 쌓아갑니다.
          </p>
        </div>
        <div className={styles.filterRow}>
          {categories.map((cat) => (
            <button
              key={cat}
              className={`${styles.filterBtn} ${active === cat ? styles.active : ''}`}
              onClick={() => setActive(cat)}
            >
              {cat}
            </button>
          ))}
        </div>
        <div className={styles.projectGrid}>
          {filtered.map((project) => (
            <div
              key={project.id}
              className={styles.projectCard}
            >
              <div className={styles.cardTop}>
                <div className={styles.meta}>
                  <span className={styles.category}>{project.category}</span>
                  <span className={styles.year}>{project.year}</span>
                </div>
                <span className={`${styles.status} ${project.status === '완료' ? styles.done : styles.ongoing}`}>
                  {project.status}
                </span>
              </div>
              <div className={styles.cardBody}>
                <h3 className={styles.cardTitle}>{project.title}</h3>
                <p className={styles.cardDesc}>{project.description}</p>
              </div>
              <div className={styles.cardFooter}>
                <div className={styles.tags}>
                  {project.tags.map((tag) => (
                    <span key={tag} className={styles.tag}>{tag}</span>
                  ))}
                </div>
                {safeUrlFor(project.url) && (
                  <a
                    href={safeUrlFor(project.url) as string}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={styles.linkBtn}
                    aria-label="자세히 보기"
                  >
                    <ArrowUpRight size={16} strokeWidth={1.5} />
                  </a>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
