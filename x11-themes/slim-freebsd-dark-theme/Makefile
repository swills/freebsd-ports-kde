# $FreeBSD$

PORTNAME=	slim-freebsd-dark-theme
DISTVERSIONPREFIX=	v
DISTVERSION=	1.0
CATEGORIES=	x11-themes

MAINTAINER=	miguel@gocobachi.dev
COMMENT=	Minimalist FreeBSD black/red colors theme for SLiM

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USE_GITHUB=	yes
GH_ACCOUNT=	gocobachi

NO_ARCH=	yes
NO_BUILD=	yes

PLIST_FILES=	${_THEMEDIR_REL}/background.png \
		${_THEMEDIR_REL}/panel.png \
		${_THEMEDIR_REL}/screenshot.png \
		${_THEMEDIR_REL}/slim.theme

_THEMEDIR_REL=	share/slim/themes/slim-freebsd-dark-theme
_THEMEDIR=	${PREFIX}/${_THEMEDIR_REL}

do-install:
	@${MKDIR} ${STAGEDIR}${_THEMEDIR}
	(cd ${WRKSRC} && \
		${COPYTREE_SHARE} . ${STAGEDIR}${_THEMEDIR} '! -name LICENSE ! -name README.md')

.include <bsd.port.mk>
